kcoreaddons_add_plugin(org.koollook.kde2
    SOURCES skeleton.cpp
    INSTALL_NAMESPACE "org.kde.kdecoration2"
)
target_link_libraries(org.koollook.kde2
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    KF6::CoreAddons
    KDecoration3::KDecoration
)
