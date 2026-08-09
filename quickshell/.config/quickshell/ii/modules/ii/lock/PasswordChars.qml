pragma ComponentBehavior: Bound
import QtQuick
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Quickshell

StyledFlickable {
    id: root

    required property int length
    property int selectionStart
    property int selectionEnd
    property int cursorPosition
    // The character just typed briefly shows as plaintext at peekIndex
    // instead of its shape, then reverts — peekIndex is -1 the rest of
    // the time (LockSurface clears it on a timer).
    property string peekChar: ""
    property int peekIndex: -1

    property color color: Appearance.colors.colPrimary
    property color selectedTextColor: Appearance.colors.colOnSecondaryContainer
    property color selectionColor: Appearance.colors.colSecondaryContainer

    property int charSize: 20

    contentWidth: dotsRow.implicitWidth
    contentX: (Math.max(contentWidth - width, 0))
    Behavior on contentX {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    Rectangle {
        id: cursor
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: root.charSize * root.cursorPosition
        }
        color: root.color
        implicitWidth: 2
        implicitHeight: root.charSize
        Behavior on anchors.leftMargin {
            animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(cursor)
        }
    }

    Row {
        id: dotsRow
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 4 - 5 // -5 to account for spacing being simulated by char item width
        }
        spacing: 0

        Repeater {
            model: ScriptModel { // TODO: use proper custom object model to insert new char at the correct pos
                values: Array(root.length)
            }

            delegate: Rectangle {
                id: charItem
                required property int index
                implicitWidth: root.charSize
                implicitHeight: root.charSize
                property bool selected: index >= root.selectionStart && index < root.selectionEnd
                readonly property bool isPeeking: index === root.peekIndex

                color: ColorUtils.transparentize(root.selectionColor, selected ? 0 : 1)

                // Briefly shows the actual character on top of its shape
                // right after it's typed, then fades back to just the
                // shape — same idea as a phone keyboard flashing the key
                // you pressed before masking it.
                StyledText {
                    anchors.centerIn: parent
                    visible: opacity > 0
                    opacity: charItem.isPeeking ? 1 : 0
                    text: charItem.isPeeking ? root.peekChar : ""
                    font.pixelSize: root.charSize * 0.7
                    color: root.color
                    Behavior on opacity {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                }
                
                MaterialShape {
                    id: materialShape
                    anchors.centerIn: parent
                    property list<var> charShapes: [
                        MaterialShape.Shape.Clover4Leaf,
                        MaterialShape.Shape.Arrow,
                        MaterialShape.Shape.Pill,
                        MaterialShape.Shape.SoftBurst,
                        MaterialShape.Shape.Diamond,
                        MaterialShape.Shape.ClamShell,
                        MaterialShape.Shape.Pentagon,
                    ]
                    shape: charShapes[charItem.index % charShapes.length]
                    // Animate on appearance
                    color: charItem.selected ? root.selectedTextColor : root.color
                    implicitSize: 0
                    opacity: 0
                    scale: 0.5
                    Component.onCompleted: {
                        appearAnim.start();
                    }
                    ParallelAnimation {
                        id: appearAnim
                        NumberAnimation {
                            target: materialShape
                            properties: "opacity"
                            to: 1
                            duration: 50
                            easing.type: Appearance.animation.elementMoveFast.type
                            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                        }
                        NumberAnimation {
                            target: materialShape
                            properties: "scale"
                            to: 1
                            duration: 200
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
                        }
                        NumberAnimation {
                            target: materialShape
                            properties: "implicitSize"
                            to: 18
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
                        }
                        ColorAnimation {
                            target: materialShape
                            properties: "color"
                            from: Appearance.colors.colPrimary
                            to: Appearance.colors.colOnLayer1
                            duration: 1000
                            easing.type: Appearance.animation.elementMoveFast.type
                            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                        }
                    }
                }
            }
        }
    }
}
