#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-split52-zmk}"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

mkdir -p .github/workflows boards/shields/split52 config zephyr

cat > .github/workflows/build.yml <<'YAML'
name: Build ZMK firmware
on: [push, pull_request, workflow_dispatch]

jobs:
  build:
    uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@v0.3.0
YAML

cat > build.yaml <<'YAML'
include:
  - board: xiao_ble
    shield: split52_left
  - board: xiao_ble
    shield: split52_right
YAML

cat > config/west.yml <<'YAML'
manifest:
  defaults:
    remote: zmkfirmware
  remotes:
    - name: zmkfirmware
      url-base: https://github.com/zmkfirmware
  projects:
    - name: zmk
      remote: zmkfirmware
      revision: v0.3.0
      import: app/west.yml
  self:
    path: config
YAML

cat > zephyr/module.yml <<'YAML'
name: zmk-keyboard-split52
build:
  settings:
    board_root: .
YAML

cat > boards/shields/split52/CMakeLists.txt <<'EOF2'
zephyr_library()
EOF2

cat > boards/shields/split52/Kconfig.shield <<'EOF2'
config SHIELD_SPLIT52_LEFT
  def_bool $(shields_list_contains,split52_left)

config SHIELD_SPLIT52_RIGHT
  def_bool $(shields_list_contains,split52_right)
EOF2

cat > boards/shields/split52/Kconfig.defconfig <<'EOF2'
if SHIELD_SPLIT52_LEFT

config ZMK_KEYBOARD_NAME
  default "split52"

config ZMK_SPLIT_ROLE_CENTRAL
  default y

endif

if SHIELD_SPLIT52_LEFT || SHIELD_SPLIT52_RIGHT

config ZMK_SPLIT
  default y

endif
EOF2

cat > boards/shields/split52/split52.zmk.yml <<'YAML'
id: split52
name: split52
type: shield
requires: [xiao_ble]
features:
  - keys
  - split
siblings:
  - split52_left
  - split52_right
YAML

cat > boards/shields/split52/split52.dtsi <<'DTS'
/ {
  chosen {
    zmk,kscan = &kscan0;
    zmk,physical-layout = &physical_layout0;
    zmk,matrix-transform = &default_transform;
  };

  kscan0: kscan0 {
    compatible = "zmk,kscan-gpio-matrix";
    wakeup-source;
    diode-direction = "col2row";
    debounce-press-ms = <5>;
    debounce-release-ms = <5>;
  };

  default_transform: matrix_transform0 {
    compatible = "zmk,matrix-transform";
    rows = <5>;
    columns = <12>;

    map = <
      /* row 0 */ RC(0,0) RC(0,1) RC(0,2) RC(0,3) RC(0,4) RC(0,5)   RC(0,6)  RC(0,7)  RC(0,8)  RC(0,9)  RC(0,10) RC(0,11)
      /* row 1 */ RC(1,0) RC(1,1) RC(1,2) RC(1,3) RC(1,4) RC(1,5)   RC(1,6)  RC(1,7)  RC(1,8)  RC(1,9)  RC(1,10) RC(1,11)
      /* row 2 */ RC(2,0) RC(2,1) RC(2,2) RC(2,3) RC(2,4) RC(2,5)   RC(2,6)  RC(2,7)  RC(2,8)  RC(2,9)  RC(2,10) RC(2,11)
      /* row 3 */ RC(3,0) RC(3,1) RC(3,2) RC(3,3) RC(3,4) RC(3,5)   RC(3,6)  RC(3,7)  RC(3,8)  RC(3,9)  RC(3,10) RC(3,11)
      /* thumbs */        RC(4,4) RC(4,5)                                         RC(4,10) RC(4,11)
    >;
  };

  physical_layout0: physical_layout0 {
    compatible = "zmk,physical-layout";
    display-name = "split52";
    kscan = <&kscan0>;
    transform = <&default_transform>;
  };
};
DTS

cat > boards/shields/split52/split52_left.overlay <<'DTS'
#include <dt-bindings/gpio/gpio.h>
#include "split52.dtsi"

&kscan0 {
  col-gpios = <
    &gpio0 29 GPIO_ACTIVE_HIGH
    &gpio0 28 GPIO_ACTIVE_HIGH
    &gpio0 3  GPIO_ACTIVE_HIGH
    &gpio0 5  GPIO_ACTIVE_HIGH
    &gpio0 4  GPIO_ACTIVE_HIGH
    &gpio1 11 GPIO_ACTIVE_HIGH
  >;

  row-gpios = <
    &gpio1 13 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio1 14 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio1 15 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio1 12 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio0 9  (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
  >;
};
DTS

cat > boards/shields/split52/split52_right.overlay <<'DTS'
#include <dt-bindings/gpio/gpio.h>
#include "split52.dtsi"

&default_transform {
  col-offset = <6>;
};

&kscan0 {
  col-gpios = <
    &gpio0 29 GPIO_ACTIVE_HIGH
    &gpio0 28 GPIO_ACTIVE_HIGH
    &gpio0 3  GPIO_ACTIVE_HIGH
    &gpio0 5  GPIO_ACTIVE_HIGH
    &gpio0 4  GPIO_ACTIVE_HIGH
    &gpio1 11 GPIO_ACTIVE_HIGH
  >;

  row-gpios = <
    &gpio1 13 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio1 14 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio1 15 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio1 12 (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
    &gpio0 9  (GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)
  >;
};
DTS

cat > config/split52_left.conf <<'CONF'
CONFIG_ZMK_KEYBOARD_NAME="split52"
CONFIG_ZMK_SPLIT=y
CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y
CONFIG_ZMK_SPLIT_BLE=y
CONFIG_ZMK_SPLIT_BLE_CENTRAL_PERIPHERALS=1
CONFIG_ZMK_USB=y
CONFIG_ZMK_BLE=y
CONFIG_NFCT_PINS_AS_GPIOS=y
CONFIG_UART_CONSOLE=n
CONF

cat > config/split52_right.conf <<'CONF'
CONFIG_ZMK_KEYBOARD_NAME="split52"
CONFIG_ZMK_SPLIT=y
CONFIG_ZMK_SPLIT_BLE=y
CONFIG_ZMK_USB=n
CONFIG_ZMK_BLE=y
CONFIG_NFCT_PINS_AS_GPIOS=y
CONFIG_UART_CONSOLE=n
CONF

cat > config/split52.keymap <<'DTS'
#include <behaviors.dtsi>
#include <dt-bindings/zmk/keys.h>

#define BASE 0
#define LOWER 1
#define RAISE 2

/ {
  keymap {
    compatible = "zmk,keymap";

    base_layer {
      bindings = <
        /* row 0 */ &kp Q   &kp W   &kp E   &kp R   &kp T   &kp Y     &kp U   &kp I     &kp O     &kp P     &kp LBKT &kp RBKT
        /* row 1 */ &kp A   &kp S   &kp D   &kp F   &kp G   &kp H     &kp J   &kp K     &kp L     &kp SEMI  &kp SQT  &kp BSLH
        /* row 2 */ &kp Z   &kp X   &kp C   &kp V   &kp B   &kp N     &kp M   &kp COMMA &kp DOT   &kp SLASH &kp MINUS &kp EQUAL
        /* row 3 */ &kp LSHFT &kp LCTRL &kp LALT &kp LGUI &kp TAB &kp ESC    &kp ENTER &kp BSPC  &kp RGUI  &kp RALT  &kp RCTRL &kp RSHFT
        /* thumbs */           &lt LOWER SPACE  &kp DEL                 &lt RAISE ENTER  &kp BSPC
      >;
    };

    lower_layer {
      bindings = <
        /* row 0 */ &kp N1 &kp N2 &kp N3 &kp N4 &kp N5 &kp N6     &kp N7 &kp N8 &kp N9 &kp N0 &kp F11 &kp F12
        /* row 1 */ &kp F1 &kp F2 &kp F3 &kp F4 &kp F5 &kp F6     &kp F7 &kp F8 &kp F9 &kp F10 &kp UP &kp INS
        /* row 2 */ &kp EXCL &kp AT &kp HASH &kp DLLR &kp PRCNT &kp CARET  &kp LEFT &kp DOWN &kp RIGHT &kp HOME &kp PG_DN &kp END
        /* row 3 */ &trans &trans &trans &trans &trans &trans      &trans &trans &trans &trans &trans &trans
        /* thumbs */               &trans &trans                   &trans &trans
      >;
    };

    raise_layer {
      bindings = <
        /* row 0 */ &kp GRAVE &kp LBRC &kp RBRC &kp LPAR &kp RPAR &kp PIPE  &kp HOME &kp PG_DN &kp PG_UP &kp END &kp BSPC &kp DEL
        /* row 1 */ &kp CAPS  &kp UNDER &kp PLUS &kp MINUS &kp EQUAL &kp BSLH &kp LEFT &kp DOWN &kp UP &kp RIGHT &kp ENTER &kp TAB
        /* row 2 */ &kp F1 &kp F2 &kp F3 &kp F4 &kp F5 &kp F6      &kp F7 &kp F8 &kp F9 &kp F10 &kp F11 &kp F12
        /* row 3 */ &trans &trans &trans &trans &trans &trans      &trans &trans &trans &trans &trans &trans
        /* thumbs */               &trans &trans                   &trans &trans
      >;
    };
  };
};
DTS

echo "Created ZMK config in: $(pwd)"
echo "Next: git init && git add . && git commit -m 'Initial ZMK config'"
