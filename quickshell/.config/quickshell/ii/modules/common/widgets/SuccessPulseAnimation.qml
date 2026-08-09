pragma ComponentBehavior: Bound
import QtQuick

// A quick scale pop, for confirming "that was right" — the positive-result
// counterpart to ErrorShakeAnimation.qml's shake.
SequentialAnimation {
    id: root

    required property Item target
    property real peakScale: 1.35

    NumberAnimation {
        target: root.target
        property: "scale"
        to: root.peakScale
        duration: 160
        easing.type: Easing.OutBack
        easing.overshoot: 2
    }
    NumberAnimation {
        target: root.target
        property: "scale"
        to: 1
        duration: 220
        easing.type: Easing.OutQuad
    }
}
