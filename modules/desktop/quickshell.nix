{ config, lib, pkgs, ... }: let
  user = config.my.user.name;
  hasQuickshell = pkgs ? quickshell;
in {
  environment.systemPackages = lib.optional hasQuickshell pkgs.quickshell;

  home-manager.users.${user} = lib.mkIf hasQuickshell {
    xdg.configFile."quickshell/quickshell.qml".text = ''
      import QtQuick
      import QtQuick.Layouts
      import QtQuick.Controls
      import Quickshell
      import Quickshell.Widgets
      import Quickshell.Hyprland

      Scope {
        id: root

        property color bg: "#0f111a"
        property color fg: "#e8e9ef"
        property color accent: "#8aadf4"
        property color muted: "#7f849c"

        PanelWindow {
          id: bar
          anchors {
            top: true
            left: true
            right: true
          }
          height: 36
          color: bg
          exclusiveZone: height
          aboveWindows: true

          RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 10

            RowLayout {
              spacing: 6
              Repeater {
                model: Hyprland.workspaces
                delegate: Rectangle {
                  required property var modelData
                  height: 24
                  width: 28
                  radius: 6
                  color: modelData.focused ? accent : (modelData.urgent ? "#e46876" : "#1a1c25")
                  border.color: modelData.focused ? accent : "#2a2c35"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: modelData.name !== "" ? modelData.name : modelData.id
                    color: modelData.focused ? bg : fg
                    font.pixelSize: 12
                    font.weight: modelData.focused ? Font.DemiBold : Font.Normal
                  }

                  MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                  }
                }
              }
            }

            Rectangle { width: 1; height: 20; color: "#2a2c35" }

            Text {
              id: title
              Layout.fillWidth: true
              text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Desktop"
              color: fg
              elide: Text.ElideRight
              font.pixelSize: 13
            }

            Rectangle { width: 1; height: 20; color: "#2a2c35" }

            RowLayout {
              spacing: 10

              Text {
                id: clock
                color: fg
                font.pixelSize: 13
                text: Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
                Timer {
                  interval: 1000
                  running: true
                  repeat: true
                  onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
                }
              }
            }
          }
        }
      }
    '';

    xdg.configFile."quickshell/README.txt".text = ''
      Quickshell starts from Hyprland exec-once.
      Edit quickshell.qml to change the bar (workspaces, title, clock).
    '';
  };
}
