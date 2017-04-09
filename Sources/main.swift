import Glibc
import SwiftyGPIO

enum Command: Int {
    case Button
}

var bluLed: GPIO?
var redLed: GPIO?
var bluButton: GPIO?
var redButton: GPIO?
let filter: UInt32 = (125 * 1000)

guard CommandLine.arguments.count == 2 else {
    print("👮 Usage:  RedBlu VALUE")
    exit(-1)
}

private func setupLEDs() {
    let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi2)

    bluLed = gpios[.P20]!
    redLed = gpios[.P26]!

    bluLed?.direction = .OUT
    redLed?.direction = .OUT

    bluLed?.value = 0
    redLed?.value = 0
}

private func setupButtons() {
    let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi2)

    bluButton = gpios[.P19]!
    redButton = gpios[.P16]!

    bluButton?.direction = .IN
    redButton?.direction = .IN
}

func switchOn(led: Command?) {
    guard let led = led else {
        return
    }

    switch(led) {
    case .Button:
        setupLEDs()
        setupButtons()

        while true {
            if let value1 = bluButton?.value, value1 == 0 {
                usleep(filter)
                if let value2 = bluButton?.value, value2 == value1 {
                    print("blu " + "\(value1)")
                    bluLed?.value = bluLed?.value == 0 ? 1 : 0
                }
            }

            if let value1 = redButton?.value, value1 == 0 {
              usleep(filter)
              if let value2 = redButton?.value, value2 == value1 {
                  print("red " + "\(value1)")
                  redLed?.value = redLed?.value == 0 ? 1 : 0
              }
            }
        }
    }
}

let led = Int(CommandLine.arguments[1])

switchOn(led: Command(rawValue:led!))
