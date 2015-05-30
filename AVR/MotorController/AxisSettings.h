/*
 * AxisSettings.h
 * Author: Jason Lefley
 * Date  : 2015-04-28
 */

#ifndef AXISSETTINGS_H
#define AXISSETTINGS_H

#include <stdint.h>

#include "Status.h"

class AxisSettings
{
public:
    AxisSettings();
    ~AxisSettings();

    // Set settings
    void SetStepAngle(int32_t value);
    void SetUnitsPerRevolution(int32_t value);
    void SetMaxJerk(int32_t value);
    void SetSpeed(int32_t value);
    void SetMicrosteppingMode(uint8_t value);

    // Retrieve settings
    float PulsesPerUnit() const;
    float MaxJerk() const;
    float Speed() const;

    Status Validate() const;
   
private:
    AxisSettings(const AxisSettings&);

private:
    // Initialize settings with defaults here
    float stepAngle = 0.0;
    float unitsPerRevolution = 0.0;
    float maxJerk = 0.0;
    float speed = 0.0;
    uint8_t microsteppingFactor = 1;
};

#endif /* AXISSETTINGS_H */
