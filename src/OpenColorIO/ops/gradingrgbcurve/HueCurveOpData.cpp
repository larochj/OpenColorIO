// SPDX-License-Identifier: BSD-3-Clause
// Copyright Contributors to the OpenColorIO Project.

#include <sstream>

#include <OpenColorIO/OpenColorIO.h>

#include "ops/gradingrgbcurve/HueCurve.h"
#include "ops/gradingrgbcurve/HueCurveOpData.h"
#include "ops/range/RangeOpData.h"
#include "Platform.h"

namespace OCIO_NAMESPACE
{

namespace DefaultValues
{
const std::streamsize FLOAT_DECIMALS = 7;
}

HueCurveOpData::HueCurveOpData(GradingStyle style)
    : OpData()
    , m_style(style)
{
    ConstHueCurveRcPtr hueCurve = HueCurve::Create(style);
    m_value = std::make_shared<DynamicPropertyHueCurveImpl>(hueCurve, false);
}

HueCurveOpData::HueCurveOpData(const HueCurveOpData & rhs)
    : OpData(rhs)
    , m_style(rhs.m_style)
{
    ConstHueCurveRcPtr hueCurve = HueCurve::Create(rhs.m_style);
    m_value = std::make_shared<DynamicPropertyHueCurveImpl>(hueCurve, false);

    *this = rhs;
}

HueCurveOpData::HueCurveOpData(GradingStyle style, 
                               const std::array<ConstGradingBSplineCurveRcPtr, HUE_NUM_CURVES> & curves)
    : OpData()
    , m_style(style)
{
    ConstHueCurveRcPtr hueCurve = HueCurve::Create(curves);
    m_value = std::make_shared<DynamicPropertyHueCurveImpl>(hueCurve, false);
}

HueCurveOpData & HueCurveOpData::operator=(const HueCurveOpData & rhs)
{
    if (this == &rhs) return *this;

    OpData::operator=(rhs);

    m_direction = rhs.m_direction;
    m_style          = rhs.m_style;
    m_bypassLinToLog = rhs.m_bypassLinToLog;

    // Copy dynamic properties. Sharing happens when needed, with CPUOp for instance.
    m_value->setValue(rhs.m_value->getValue());
    if (rhs.m_value->isDynamic())
    {
        m_value->makeDynamic();
    }

    return *this;
}

HueCurveOpData::~HueCurveOpData()
{
}

HueCurveOpDataRcPtr HueCurveOpData::clone() const
{
    return std::make_shared<HueCurveOpData>(*this);
}

void HueCurveOpData::validate() const
{
    // This should already be valid.
    m_value->getValue()->validate();
    return;
}

bool HueCurveOpData::isNoOp() const
{
    return isIdentity();
}

bool HueCurveOpData::isIdentity() const
{
    if (isDynamic()) return false;
    
    return m_value->getValue()->isIdentity();
}

bool HueCurveOpData::isInverse(ConstHueCurveOpDataRcPtr & r) const
{
    if (isDynamic() || r->isDynamic())
    {
        return false;
    }

    if (m_style == r->m_style &&
        (m_style != GRADING_LIN || m_bypassLinToLog == r->m_bypassLinToLog) &&
        m_value->equals(*r->m_value))
    {
        if (CombineTransformDirections(getDirection(), r->getDirection()) == TRANSFORM_DIR_INVERSE)
        {
            return true;
        }
    }
    return false;
}

HueCurveOpDataRcPtr HueCurveOpData::inverse() const
{
    auto res = clone();
    res->m_direction = GetInverseTransformDirection(m_direction);
    return res;
}

std::string HueCurveOpData::getCacheID() const
{
    AutoMutex lock(m_mutex);

    std::ostringstream cacheIDStream;
    if (!getID().empty())
    {
        cacheIDStream << getID() << " ";
    }

    cacheIDStream.precision(DefaultValues::FLOAT_DECIMALS);

    cacheIDStream << GradingStyleToString(getStyle()) << " ";
    cacheIDStream << TransformDirectionToString(getDirection()) << " ";
    if (m_bypassLinToLog)
    {
        cacheIDStream << " bypassLinToLog";
    }
    if (!isDynamic())
    {
        cacheIDStream << *(m_value->getValue());
    }
    return cacheIDStream.str();
}

void HueCurveOpData::setStyle(GradingStyle style) noexcept
{
    if (style != m_style)
    {
        m_style = style;
        // Reset value to default when style is changing.
        ConstHueCurveRcPtr reset = HueCurve::Create(style);
        m_value->setValue(reset);
    }
}

float HueCurveOpData::getSlope(HueCurveType c, size_t index) const
{
    ConstGradingBSplineCurveRcPtr curve = m_value->getValue()->getCurve(c);
    return curve->getSlope(index);
}

void HueCurveOpData::setSlope(HueCurveType c, size_t index, float slope)
{
    HueCurveRcPtr hueCurve( m_value->getValue()->createEditableCopy() );
    GradingBSplineCurveRcPtr curve = hueCurve->getCurve(c);
    curve->setSlope(index, slope);
    m_value->setValue(hueCurve);
}

bool HueCurveOpData::slopesAreDefault(HueCurveType c) const
{
    ConstGradingBSplineCurveRcPtr curve = m_value->getValue()->getCurve(c);
    return curve->slopesAreDefault();
}

TransformDirection HueCurveOpData::getDirection() const noexcept
{
    return m_direction;
}

void HueCurveOpData::setDirection(TransformDirection dir) noexcept
{
    m_direction = dir;
}

bool HueCurveOpData::isDynamic() const noexcept
{
    return m_value->isDynamic();
}

DynamicPropertyRcPtr HueCurveOpData::getDynamicProperty() const noexcept
{
    return m_value;
}

void HueCurveOpData::replaceDynamicProperty(DynamicPropertyHueCurveImplRcPtr prop) noexcept
{
    m_value = prop;
}

void HueCurveOpData::removeDynamicProperty() noexcept
{
    m_value->makeNonDynamic();
}

bool HueCurveOpData::equals(const OpData & other) const
{
    if (!OpData::equals(other)) return false;

    const HueCurveOpData* rop = static_cast<const HueCurveOpData*>(&other);

    if (m_direction      != rop->m_direction ||
        m_style          != rop->m_style ||
        m_bypassLinToLog != rop->m_bypassLinToLog ||
       !m_value->equals(  *(rop->m_value)  ))
    {
        return false;
    }

    return true;
}

bool operator==(const HueCurveOpData & lhs, const HueCurveOpData & rhs)
{
    return lhs.equals(rhs);
}

} // namespace OCIO_NAMESPACE
