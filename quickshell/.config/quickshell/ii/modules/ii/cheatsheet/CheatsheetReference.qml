pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

// A quick-reference sheet of common math/physics/CS formulas and
// constants — general enough to be useful to most students, distinct
// from the Hyprland-specific Keybinds tab and the chemistry-specific
// Elements tab.
Item {
    id: root
    implicitWidth: QsWindow?.window?.screen.width * 0.7 ?? 0
    implicitHeight: QsWindow?.window?.screen.height * 0.7 ?? 0

    readonly property var categories: [
        {
            icon: "function",
            name: Translation.tr("Math"),
            items: [
                { label: Translation.tr("Quadratic formula"), value: "x = (-b ± √(b² - 4ac)) / 2a" },
                { label: Translation.tr("Pythagorean theorem"), value: "a² + b² = c²" },
                { label: Translation.tr("Slope-intercept"), value: "y = mx + b" },
                { label: Translation.tr("Distance"), value: "√((x₂-x₁)² + (y₂-y₁)²)" },
                { label: Translation.tr("Circle area"), value: "A = πr²" },
                { label: Translation.tr("Circle circumference"), value: "C = 2πr" },
                { label: Translation.tr("Sphere volume"), value: "V = (4/3)πr³" },
                { label: Translation.tr("Compound interest"), value: "A = P(1 + r/n)^(nt)" },
            ]
        },
        {
            icon: "bolt",
            name: Translation.tr("Physics"),
            items: [
                { label: Translation.tr("Speed of light (c)"), value: "2.998 × 10⁸ m/s" },
                { label: Translation.tr("Gravitational constant (G)"), value: "6.674 × 10⁻¹¹ N·m²/kg²" },
                { label: Translation.tr("Planck's constant (h)"), value: "6.626 × 10⁻³⁴ J·s" },
                { label: Translation.tr("Avogadro's number (Nₐ)"), value: "6.022 × 10²³ /mol" },
                { label: Translation.tr("Gas constant (R)"), value: "8.314 J/(mol·K)" },
                { label: Translation.tr("Newton's second law"), value: "F = ma" },
                { label: Translation.tr("Kinetic energy"), value: "KE = ½mv²" },
                { label: Translation.tr("Ohm's law"), value: "V = IR" },
                { label: Translation.tr("Power"), value: "P = VI = I²R = V²/R" },
            ]
        },
        {
            icon: "terminal",
            name: Translation.tr("Computer Science"),
            items: [
                { label: "O(1)", value: Translation.tr("Constant") },
                { label: "O(log n)", value: Translation.tr("Logarithmic — e.g. binary search") },
                { label: "O(n)", value: Translation.tr("Linear — e.g. single loop") },
                { label: "O(n log n)", value: Translation.tr("Log-linear — e.g. merge/quick sort") },
                { label: "O(n²)", value: Translation.tr("Quadratic — e.g. nested loops") },
                { label: "O(2ⁿ)", value: Translation.tr("Exponential — e.g. naive recursion") },
                { label: Translation.tr("ASCII 'A' / 'a' / '0'"), value: "65 / 97 / 48" },
                { label: Translation.tr("1 KB / MB / GB"), value: "1024 B / 1024² B / 1024³ B" },
            ]
        },
    ]

    StyledFlickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: Appearance.rounding.small
        clip: true
        contentWidth: width
        contentHeight: flow.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Flow {
            id: flow
            width: flickable.width
            spacing: 12

            Repeater {
                model: root.categories
                delegate: ReferenceCategory {
                    required property var modelData
                    categoryData: modelData
                }
            }
        }
    }

    ScrollEdgeFade {
        target: flickable
        vertical: true
        color: Appearance.colors.colLayer0Base
    }

    // Explicit scroll buttons as a guaranteed way to reach the edges,
    // regardless of whether wheel/trackpad scroll reaches the Flickable.
    // Bigger and pulled in further from the edge than before (was 32px at
    // a 4px margin, easy to miss and easy to fat-finger the content behind
    // it instead) — matches the periodic table's scroll buttons.
    component ScrollStepButton: RippleButton {
        id: stepBtn
        required property real direction // -1 or 1
        implicitWidth: 40
        implicitHeight: 40
        buttonRadius: Appearance.rounding.full
        colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.95)
        colBackgroundHover: Appearance.colors.colPrimaryContainer
        visible: stepBtn.direction < 0 ? flickable.contentY > 1 : flickable.contentY < flickable.contentHeight - flickable.height - 1
        onClicked: {
            const maxY = Math.max(0, flickable.contentHeight - flickable.height);
            flickable.contentY = Math.max(0, Math.min(maxY, flickable.contentY + stepBtn.direction * flickable.height * 0.6));
        }
        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            iconSize: 22
            text: stepBtn.direction < 0 ? "keyboard_arrow_up" : "keyboard_arrow_down"
            color: Appearance.colors.colOnLayer0
        }
    }

    StyledRectangularShadow { target: topScrollBtn; opacity: topScrollBtn.visible ? 1 : 0 }
    ScrollStepButton {
        id: topScrollBtn
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 14 }
        direction: -1
    }
    StyledRectangularShadow { target: bottomScrollBtn; opacity: bottomScrollBtn.visible ? 1 : 0 }
    ScrollStepButton {
        id: bottomScrollBtn
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 14 }
        direction: 1
    }

    component ReferenceCategory: Rectangle {
        id: card
        required property var categoryData
        width: Math.min(flickable.width, 340)
        implicitHeight: cardColumn.implicitHeight + 24
        radius: Appearance.rounding.normal
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colLayer0Border

        ColumnLayout {
            id: cardColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 8

            RowLayout {
                spacing: 6
                MaterialSymbol {
                    text: card.categoryData.icon
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colPrimary
                }
                StyledText {
                    text: card.categoryData.name
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnLayer1
                }
            }

            Repeater {
                model: card.categoryData.items
                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: modelData.label
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.value
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer1
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
