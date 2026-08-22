var plasma = getApiVersion(1);

var layout = {
    "desktops": [
        {
            "applets": [
                {
                    "config": {
                        "/General": {
                            "latitude": "59.43696",
                            "location": "Tallinn",
                            "longitude": "24.75353"
                        }
                    },
                    "geometry.height": 0,
                    "geometry.width": 0,
                    "geometry.x": 0,
                    "geometry.y": 0,
                    "plugin": "com.koollook.weather",
                    "title": "Koollook Weather"
                },
                {
                    "config": {
                        "/General": {
                            "enabledCalendarPlugins": "holidaysevents,astronomicalevents",
                            "firstDayOfWeek": "1"
                        }
                    },
                    "geometry.height": 0,
                    "geometry.width": 0,
                    "geometry.x": 0,
                    "geometry.y": 0,
                    "plugin": "com.koollook.calendar",
                    "title": "Koollook Calendar"
                },
                {
                    "config": {
                        "/General": {
                            "latitude": "59.43696",
                            "location": "Tallinn",
                            "longitude": "24.75353"
                        }
                    },
                    "geometry.height": 0,
                    "geometry.width": 0,
                    "geometry.x": 0,
                    "geometry.y": 0,
                    "plugin": "com.koollook.planisphere",
                    "title": "Koollook Planisphere"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/Wallpaper/org.kde.image/General": {
                    "SlidePaths": "/usr/share/wallpapers/"
                }
            },
            "wallpaperPlugin": "org.kde.image"
        }
    ],
    "panels": [
        {
            "alignment": "center",
            "applets": [
                { "plugin": "org.kde.plasma.kickoff" },
                { "plugin": "org.kde.plasma.icontasks" },
                { "plugin": "org.kde.plasma.systemtray" },
                { "plugin": "org.kde.plasma.weather" },
                { "plugin": "org.kde.plasma.digitalclock" },
                { "plugin": "org.kde.plasma.minimizeall" }
            ],
            "config": {
                "/": {
                    "formfactor": "2",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                }
            },
            "height": 2.8,
            "hiding": "normal",
            "lengthMode": "fill",
            "location": "bottom",
            "opacity": "translucent"
        }
    ],
    "serializationFormatVersion": "1"
};

plasma.loadSerializedLayout(layout);
