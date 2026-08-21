// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigami.delegates as KD
import org.kde.kholidays as KHolidays
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.holidayevents as HolidayEvents

Item {
    id: root
    implicitWidth: Kirigami.Units.gridUnit * 28
    implicitHeight: Kirigami.Units.gridUnit * 28

    property string title
    property var cfg_enabledCalendarPlugins
    property var cfg_enabledCalendarPluginsDefault
    property var cfg_firstDayOfWeek
    property var cfg_firstDayOfWeekDefault
    property var cfg_showWeekNumbers
    property var cfg_showWeekNumbersDefault
    property var cfg_styleMode
    property var cfg_styleModeDefault
    property var cfg_appearance
    property var cfg_appearanceDefault
    property var cfg_cornerRadius
    property var cfg_cornerRadiusDefault
    property var cfg_roundnessX10
    property var cfg_roundnessX10Default
    property var cfg_refractThickness
    property var cfg_refractThicknessDefault
    property var cfg_refractIORx100
    property var cfg_refractIORx100Default
    property var cfg_refractScale
    property var cfg_refractScaleDefault
    property var cfg_tintAlphaPct
    property var cfg_tintAlphaPctDefault
    property var cfg_chromaStrengthPct
    property var cfg_chromaStrengthPctDefault
    property var cfg_specStrengthPct
    property var cfg_specStrengthPctDefault
    property var cfg_blurRadiusPx
    property var cfg_blurRadiusPxDefault
    property var cfg_realtimeRefraction
    property var cfg_realtimeRefractionDefault
    property var cfg_hideFrame
    property var cfg_hideFrameDefault

    HolidayEvents.HolidayRegionsConfig {
        id: regions
    }

    function _ensurePlugin() {
        var list = cfg_enabledCalendarPlugins
        var arr = []
        if (typeof list === "string")
            arr = list.split(",").filter(function (s) { return s.length })
        else if (list) {
            for (var i = 0; i < list.length; i++)
                arr.push(list[i])
        }
        if (arr.indexOf("holidaysevents") === -1)
            arr.push("holidaysevents")
        cfg_enabledCalendarPlugins = arr
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.SearchField {
            id: filter
            Layout.fillWidth: true
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: holidaysView
                clip: true
                model: KItemModels.KSortFilterProxyModel {
                    sourceModel: KHolidays.HolidayRegionsModel {}
                    filterCaseSensitivity: Qt.CaseInsensitive
                    filterString: filter.text
                    filterRoleName: "name"
                }
                delegate: QQC2.CheckDelegate {
                    required property string region
                    required property string name
                    required property string description
                    width: ListView.view.width
                    text: name
                    checked: regions.selectedRegions.indexOf(region) !== -1
                    contentItem: KD.TitleSubtitle {
                        title: name
                        subtitle: description
                    }
                    onToggled: {
                        if (checked)
                            regions.addRegion(region)
                        else
                            regions.removeRegion(region)
                        regions.saveConfig()
                        root._ensurePlugin()
                    }
                }
            }
        }
    }
}
