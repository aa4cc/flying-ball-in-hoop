---
layout: page
title: Building Instructions
subtitle: How to build your own Ball in Hoop laboratory model
---

# Ball in Hoop 

## Introduction

Our motivation for developing the Ball In Hoop model was to demonstrate non-trivial, complex control algorithms on a simple, easy-to-make and compact model. As the name suggests, the model consists of the ball and the hoop. The ball can freely rotate in the hoop and the hoop is attached to a motor which allows us to exert a torque on the hoop. The goal is to damp the undesired oscillations of the ball. In other words, the goal is to calculate a torque acting against the oscillations based on the measured position of the ball.

This repository should help you to make this model on your own. It provides a step-by-step guide. Please bear in mind that the whole project is still in development. That means there is always a plenty of possible improvements and even we ourselves made several changes and deflected slightly from the guide written below.

The theoretical background of the model is explained in following paper:

For exploring our previous version of the model and its capabilities please check these sites and videos:

## Design

You can see the arrangement of the model in the following picture.An acrylic board bears an electronics box and a motor holder. Concerning the hoop holder, there are ODrive Driver, ODrive Motor (bearing the hoop) and matching encoder attached to it. The electronics box includes Raspberry Pi 3b+, a step-down converter (from 48VDC to 5VDC), a smaller box for balls and a light module holder (which bears the Raspberry Pi Camera V1). 

### Acrylic board

It actually consists of two acrylics with dimensions 450x230x5mm. They stand on four small rubber legs. There are eight holes in the board - seven mounting holes and one hole for cabels. The displacement of the holes can be seen in following picture:

### Light

The whole concept of a model light differs completely from the previous version of the model (*version 1*). Previously, we dismantled a LED bulb and used its components to make the model light. Now, we decided to make the light on our own. Thus, we have made a schematic and a PCB in Autodesk Eagle PCB designer.

#### Overall concept

As it is seen in the picture, the main part of the light are two branches with 12 LEDs each. They are arranged in 2 concentric circles. In the centre of these circles there is a hole (7mm diameter) for camera lense. In the space between this hole and the LEDs there are 6 mounting holes, 4 for attaching the camera to the board and 2 for mounting the whole module (light board + camera) to a holder. Beneath this "circular" part there is a "rectangular" part of the light control. Taking from left to right, there are two inductors, two Schottky diodes, two LED drivers, two resistors and two capacitors and the data (PWM) connector, the power connector and a trimmer and a solder jumper and a 182k resistor. The wiring is based on a schematic shown in the datasheet of the AP8801 driver.

#### Components
 (numbers hold for one board)

- LEDs: OSRAM DURIS E5 GW-JDSTS2.EM, 24 pieces; http://www.farnell.com/datasheets/2291111.pdf

- LED driver (current regulator): DIODES AP8801, 2 pieces; http://www.farnell.com/datasheets/2100281.pdf?_ga=2.245177093.1296125616.1532690079-1921296706.1532510386
- Capacitors: HMK325BJ475KN-TE, 2 pieces; https://cz.mouser.com/datasheet/2/396/mlcc02_e-1307760.pdf
- Inductors: SRN8040TA-101M, 2 pieces; https://cz.mouser.com/datasheet/2/54/rn8040ta-964790.pdf
- Resistors: RK73H1JTTD1R10F, 2 pieces; http://www.farnell.com/datasheets/549017.pdf?_ga=2.245379204.1296125616.1532690079-1921296706.1532510386
- Schottky diode: SS1H10-E3/61T, 2 pieces; http://www.farnell.com/datasheets/2614068.pdf?_ga=2.245379204.1296125616.1532690079-1921296706.1532510386
- Trimmer: TC33X-2-103E, 1 piece; http://www.farnell.com/datasheets/2146212.pdf?_ga=2.245379204.1296125616.1532690079-1921296706.1532510386
- Resistor: 182k, 1 piece

The values of the components were determined based on the LED driver (AP8801) datasheet.

#### Functionalities

The two LED branches can be separately controlled by pulse-width modulation (which comes in through the CTRL pin of the LED drivers). To use PWM, do not solder the trimmer to the board and let the solder jumper disconnected. Optionally, if you do not want to use PWM, you may solder the trimmer and the solder jumper which makes you able to dim both LED branches at once using the trimmer.

#### Connectors

- POWER-1 - +48V
- POWER-2 - GND
- CTRL-1 - GND
- CTRL-2 - RASPBERRY Pi PWM (channel 1)
- CTRL-3 - RASPBERRY Pi PWM (channel 2)

### Box

The electronics box is made of 5mm thick plywood. Dimensions: 23x11x4 centimeters. We designed the box in Fusion 360 and used the sketches for cutting the sides of the box in laser cut. The assembly can be easily seen in following photos.

#### Front side

Taking from left to right, there is a 15mm switch hole, beneath this switch hole is a 4.9mm hole for indication led, then there is an 8mm hole for input voltage, a 15mm hole for a DIN connector (it provides access to Raspberry Pi pins), a 16mm hole for a Raspberry Pi shutdown button and lastly a second hole for an indication LED.

#### Components 

- ON/OFF switch, panel mount
- DC power connector, jack, 2.1mm x 5.5mm, panel mount
- DIN 5 female connector, panel mount, 180°
- button, panel mount