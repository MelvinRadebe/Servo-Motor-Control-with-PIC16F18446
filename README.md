Servo Motor Control with PIC16F18446
This project is a low-level assembly implementation for controlling a servo motor using the PIC16F18446 microcontroller. The motor's position is adjusted based on analog input from a potentiometer, read via the ADC, and translated into a PWM signal on RA4 using CCP4.

📌 Features
Reads analog input from RA1 (ANA1) via ADC

Outputs PWM signal on RA4 to control servo motor position

Uses Timer2 for PWM timing

Implements a 3-stage duty cycle decision logic for refined positioning

All control logic written in MPASM Assembly

🔧 Hardware Requirements
PIC16F18446 microcontroller

Servo motor (standard PWM-controlled, 50 Hz)

Potentiometer (for analog input)

Power supply (e.g., 5V regulated)

RA1 connected to potentiometer wiper (0–5V)

RA4 connected to servo motor signal pin

🔁 How It Works
ADC Setup:

Channel ANA1 (RA1) selected

Vref+ = VDD (5V), Vref− = AVSS (0V)

8-bit resolution (ADRESH only)

PWM Output Setup:

RA4 configured for CCP4 output

PWM mode selected with right alignment

Timer2 configured as PWM timebase

Control Logic:

The ADC value is read and processed by a multi-stage subroutine (DUTYTEST, test2, test3)

Depending on specific bit patterns in the ADC result, a corresponding PWM duty cycle is loaded

This duty cycle drives the servo to a corresponding position (e.g., left, center, right)

🛠 Key Registers Used
Register	Purpose
RA1 (ANA1)	ADC input from potentiometer
RA4	PWM output to servo motor
ADRESH	Holds ADC high byte result
CCPR4L/H	Holds PWM duty cycle
T2CON, T2PR	Timer2 control and period register
PIR4	Timer2 interrupt flag

🔁 PWM Tuning Logic
The PWM output (duty cycle) is fine-tuned based on ADC input:

If bit 7 in ADC result is set → duty = 80 (center position)

If mid bits are set (5–6) → re-evaluate using second-level tests

Final adjustment in test3 → duty = 47, or if certain bits unset, duty remains as-is

These thresholds allow custom positioning for:

Left

Right

Center

Or intermediate positions

🧪 Subroutines
Subroutine	Purpose
DUTYTEST	First check of ADC bits for duty decision
test2	Second level refinement
test3	Final decision before output
timer	Timer2 configuration
delay	Wait for Timer2 flag to indicate period complete

▶️ Usage Instructions
Assemble the code using MPLAB X and MPASM toolchain.

Flash the .hex to your PIC16F18446.

Connect:

Potentiometer to RA1

Servo signal pin to RA4

Power on the circuit.

Rotate the potentiometer to move the servo accordingly.

📚 Notes
Ensure Timer2 period matches 50Hz (20ms) typical for servo motors.

The values for duty cycle (18, 47, 80, etc.) correspond to pulse widths like 1ms, 1.5ms, 2ms (typical for servo min, center, max).

Adjust T2PR and CCPR4L values for finer control depending on your specific servo timing needs.
