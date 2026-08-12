import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_userLat: latField.value
    property alias cfg_userLon: lonField.value
    property alias cfg_planetScale: scaleSlider.value
    property alias cfg_bgOpacity: opacitySlider.value
    property alias cfg_glassTintAlpha: tintSlider.value
    property alias cfg_glassBlur: blurSlider.value
    property alias cfg_glassRadius: radiusSlider.value

    SpinBox {
        id: latField
        Kirigami.FormData.label: "Latitude:"
        from: -90
        to: 90
        stepSize: 1
        value: 59
    }

    SpinBox {
        id: lonField
        Kirigami.FormData.label: "Longitude:"
        from: -180
        to: 180
        stepSize: 1
        value: 24
    }

    Slider {
        id: scaleSlider
        Kirigami.FormData.label: "Planet size:"
        from: 0.5
        to: 3.0
        stepSize: 0.1
        value: 1.0
    }

    Slider {
        id: opacitySlider
        Kirigami.FormData.label: "Canvas fill (0 = transparent):"
        from: 0.0
        to: 1.0
        stepSize: 0.05
        value: 0.0
    }

    Slider {
        id: tintSlider
        Kirigami.FormData.label: "Glass frame tint:"
        from: 0.0
        to: 0.4
        stepSize: 0.02
        value: 0.12
    }

    Slider {
        id: blurSlider
        Kirigami.FormData.label: "Glass blur:"
        from: 0
        to: 24
        stepSize: 1
        value: 6
    }

    Slider {
        id: radiusSlider
        Kirigami.FormData.label: "Corner radius:"
        from: 8
        to: 64
        stepSize: 1
        value: 28
    }
}
