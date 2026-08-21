import QtQuick
import org.kde.kwin.decoration
import org.kde.ksvg as KSvg

DecorationButton {
    id: root
    required property string svgFile
    property int btnWidth: 44
    property int btnHeight: 28
    width: btnWidth
    height: btnHeight

    KSvg.FrameSvgItem {
        anchors.fill: parent
        imagePath: Qt.resolvedUrl(root.svgFile)
        prefix: {
            var act = decoration.client.active
            if (!root.enabled)
                return act ? "deactivated" : "deactivated-inactive"
            if (root.pressed)
                return act ? "pressed" : "pressed-inactive"
            if (root.hovered)
                return act ? "hover" : "hover-inactive"
            return act ? "active" : "inactive"
        }
    }
}
