// for udp communication:
import hypermedia.net.*;

// to get screen and display info:
import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;

// to retrieve day of the week:
import java.util.Calendar;

boolean configError = false;

int numberOfClocks = 1;   // default always 1

FileCache cache;
ClockWindowManager[] clockWindowManager;

UDP companionUdp;
boolean companionEnable;
String companionIp;
int companionPort;
int companionInterval;

int companionTimer;

int[] companionPage;
int[] companionButton;
boolean[] companionPreviousVisState;

void setup() {
  // setup cache file:
  cache = new FileCache("cache.dat");

  // set up Companion udp:
  companionUdp = new UDP(this);

  // set main surface invsible:
  surface.setVisible(false);
  size(500, 200);

  {
    String keyReturnStr;
    IniParse iniConfig = new IniParse("config.ini");
    if (!iniConfig.exists()) {  // error
      PrintWriter newConfig = createWriter("config.ini");
      newConfig.print("; wallClock configuration template\n; values can be set to keys using \" = \"\n; \";\" or \"#\" can be used to comment throughout ini file\n\n                ; *\"numberOfClocks\" is optional. default will always be '1'. this key has to be but before any other groups \"[group]\" or can be put under an empty group: \"[]\"\nnumberOfClocks  ; declared the number of clocks to be rendered. format: 2 range: 1 - 10\n\n; companion config:\n[companion]\n  sendEnable ; if set \"true\", wallClock will send visibility status to designated companion. format: \"true\" or \"false\" (boolean)\n\n      ; *\"ip\" key only required if \"sendEnable\" is set \"true\"\n  ip  ; ip address of target companion. format: \"34.5.0.32\" range: 0.0.0.0 - 255.255.255.255 or \"localhost\" if companion is on same device\n\n        ; *\"port\" key only required if \"sendEnable\" is set \"true\"\n  port  ; port of target companion. format: \"6565\" range: 0 - 65535\n\n            ; *\"interval\" key only required if \"sendEnable\" is set \"true\"\n  interval  ; interval(in milliseconds) that status will be updated(for reliability). format: \"500\" range: >=100 (0 = interval-disabled, *updates will only be sent onChange)\n\n  ; page and button will be configed individually for each clock\n\n\n\n; The Rest of the Configuration is for each individual WallClock\n; Depending on the number of wallClocks configured, you may need to repeat the configuration for each clock by incrementing the clock count/id at the end of each group-name starting from #1 eg. clock_general_1, clock_general_2, etc.\n\n; general-clock configuration:\n[clock_general_1]\n  startUp ; set whether clock boots up on(visible/\"true\") or off(not-visible/\"false\"). format: \"true\" or \"false\"\n\n  screen ; set which screen the clock starts on. set to \"auto\" to use previously used screen from last boot. format: 1 - 10(static) or \"auto\"(dynamic)\n\n  ; *\"background\" key is optional. default is '000000' or black\n  background ; set background color of clock. Set using hexadecimal format (rgb). format: \"ffffff\"(white), \"ff0000\"(red), \"00ff00\"(green) (*DO NOT USE '#' char when seting color)\n\n  ; *\"text\" key is optional. default is '0' or black\n  text ; set all text color of clock. Set using hexadecimal format (rgb). format: \"ffffff\"(white), \"ff0000\"(red), \"00ff00\"(green) (*DO NOT USE '#' char when seting color)\n\n  ; *\"shadowOpacity\" key is optional. default is '0%' or no shadow\n  shadowOpacity ; set shadow opacity of text(*note: shadow is useless when using black background). format: \"0%\" - \"100%\" (*note: '%' may be used although not necessary)\n\n            ; *\"shadow_x\" is optional. default is '0'(no offset)\n  shadow_x  ; offset the shadow position in x-axis. default is always '0'(*note: no offset is effectivly no shadow as it is hidden behind the text) format: (any int +(right-offset) -(left-offset))\n\n            ; *\"shadow_y\" is optional. default is '0'(no offset)\n  shadow_y  ; offset the shadow position in y-axis. default is always '0'(*note: no offset is effectivly no shadow as it is hidden behind the text) format: (any int +(right-offset) -(left-offset))\n\n; companion configuration for wall-clock:\n[clock_companion_1]\n        ; *\"page\" key only required if [companion] \"sendEnable\" is set \"true\"\n  page  ; target page of companion. format: \"8\" range: 1 - 99\n\n          ; *\"button\" key only required if [companion] \"sendEnable\" is set \"true\"\n  button  ; target button of companion. format: \"12\" range: 1 - 32\n\n; udp listen configuration for wall-clock:\n[clock_udp_1]\n  enableListen ; if set \"true\", wallClock will accept commands from a udp port. format: \"true\" or \"false\" (boolean)\n\n        ; *\"port\" key only required if \"enableListen\" is set \"true\"\n  port  ; port that wallClock will listen to(port must be available else error will occur). format: \"5005\" range: 0 - 65535\n\n; time portion of clock config:\n[clock_time]\n  enable  ; if set \"true\", time will be rendered. set \"false\" to disable time-render. format: \"true\" or \"false\" (boolean)\n\n        ; *\"font\" key is required regardless of \"enable\" for rendering purposes\n  font  ; font of time. format: \"digital - 7.ttf\" (any installed-font, local-path, or full-path)\n\n        ; *\"size\" key is required regardless of \"enable\" for rendering purposes\n  size  ; size of font for time. format: \"500\" (size in pt.)\n\n              ; *\"leadingZero\" key only required if \"enable\" is set \"true\"\n  leadingZero ; set \"true\" to add a '0' before the hour if it is less than the number '10'. format: \"true\" or \"false\" (boolean)\n\n            ; *\"offset_x\" is optional. default is '0'(no offset)\n  offset_x  ; offset the time position in x-axis. default is always '0'. format: (any int +(right-offset) -(left-offset))\n\n            ; *\"offset_y\" is optional. default is '0'(no offset)\n  offset_y  ; offset the time position in y-axis. default is always '0'. format: (any int +(down-offset) -(up-offset))\n\n; date portion of clock config:\n[clock_date]\n  enable  ; if set \"true\", date will be rendered. set \"false\" to disable date-render. format: \"true\" or \"false\" (boolean)\n\n        ; *\"font\" key is required regardless of \"enable\" for rendering purposes\n  font  ; font of date. format: \"digital - 7.ttf\" (any installed-font, local-path, or full-path)\n\n        ; *\"size\" key is required regardless of \"enable\" for rendering purposes\n  size  ; size of font for date. format: \"80\" (size in pt.)\n\n            ; *\"offset_x\" is optional. default is '0'(no offset)\n  offset_x  ; offset the date position in x-axis. default is always '0'. format: (any int +(right-offset) -(left-offset))\n\n            ; *\"offset_y\" is optional. default is '0'(no offset)\n  offset_y  ; offset the date position in y-axis. default is always '0'. format: (any int +(down-offset) -(up-offset))\n\n; am-pm portion of clock config:\n[clock_ampm]\n  enable  ; if set \"true\", am-pm will be rendered. set \"false\" to disable am-pm-render. format: \"true\" or \"false\" (boolean)\n\n        ; *\"font\" key is required regardless of \"enable\" for rendering purposes\n  font  ; font of am-pm. format: \"digital - 7.ttf\" (any installed-font, local-path, or full-path)\n\n        ; *\"size\" key is required regardless of \"enable\" for rendering purposes\n  size  ; size of font for am-pm. format: \"200\" (size in pt.)\n\n            ; *\"offset_x\" is optional. default is '0'(no offset)\n  offset_x  ; offset the am-pm position in x-axis. default is always '0'. format: (any int +(right-offset) -(left-offset))\n\n            ; *\"offset_y\" is optional. default is '0'(no offset)\n  offset_y  ; offset the am-pm position in y-axis. default is always '0'. format: (any int +(down-offset) -(up-offset))\n");
      newConfig.flush(); // Writes the remaining data to the file
      newConfig.close(); // Finishes the file
      sendErrorCode("\"\\config.ini\" NOT FOUND\nINI TEMPLATE GENERATED");
      return;
    }
    // parse configuration from ini:
    /*
    |Vals to Check:
     | - NumOfScreens
     | - Companion
     |   - Send Companion Enable
     |   - Companion Ip
     |   - Companion Port
     |   - Companion Interval
     | - Clock
     |   - Clock
     |     - StartUp(on, off)
     |     - Screen(ScreenNum or "auto")
     |     - BackgroundColor(hex)
     |     - TextColor(hex)
     |     - ShadowOpacity(%)
     |     - Shadow_x
     |     - Shadow_y
     |   - Companion
     |     - Page
     |     - Button
     |   - UDP
     |     - Enable Listen
     |     - Port (Listening) (must be an open port)
     |   - Time
     |     - Enable
     |     - Font
     |     - Size
     |     - Offset_X
     |     - Offset_Y
     |     - LeadingHourZero
     |   - Date
     |     - Enable
     |     - Font
     |     - Size
     |     - Offset_X
     |     - Offset_Y
     |   - AmPm
     |     - Enable
     |     - Font
     |     - Size
     |     - Offset_X
     |     - Offset_Y
     */

    // number of clocks:
    {
      keyReturnStr = iniConfig.getVal("", "numberOfClocks");
      if (keyReturnStr != null) { // optional key. default: 1
        if (keyReturnStr.equals("")) {  // key not declared
          sendErrorCode("\"\\config.ini\"\n[] numberOfClocks\nKEY NOT DECLARED");
          return;
        }
        if (!checkInt(keyReturnStr)) {
          sendErrorCode("\"\\config.ini\"\n[] numberOfClocks = \"" + keyReturnStr + "\"\nINVALID INT");
          return;
        }

        numberOfClocks = int(keyReturnStr);
        if (numberOfClocks > 10 || numberOfClocks < 1) {
          sendErrorCode("\"\\config.ini\"\n[] numberOfClocks = \"" + keyReturnStr + "\"\nKEY OUT OF RANGE(1 - 10)");
          return;
        }
      } else {
        numberOfClocks = 1;
      }

      clockWindowManager = new ClockWindowManager[numberOfClocks];
      companionPage = new int[numberOfClocks];
      companionButton = new int[numberOfClocks];
      companionPreviousVisState = new boolean[numberOfClocks];

      for (int x = 0; x < numberOfClocks; x++) {
        clockWindowManager[x] = new ClockWindowManager();
      }
    }

    // Companion:
    {
      { // send enable:
        keyReturnStr = iniConfig.getVal("companion", "sendEnable");
        if (keyReturnStr == null) {
          sendErrorCode("\"\\config.ini\"\n[companion] sendEnable\nKEY NOT FOUND");
          return;
        }
        if (keyReturnStr.equals("")) {
          sendErrorCode("\"\\config.ini\"\n[companion] sendEnable\nKEY NOT DECLARED");
          return;
        }
        if (keyReturnStr.equals("true")) {
          companionEnable = true;
        } else if (keyReturnStr.equals("false")) {
          companionEnable = false;
        } else {
          sendErrorCode("\"\\config.ini\"\n[companion] sendEnable = \"" + keyReturnStr + "\"\nKEY MUST EQUAL: \"true\" or \"false\"");
          return;
        }
      }

      if (companionEnable) { // rest of the companion config is only required if "companionEnable" set true;
        { // ip:
          keyReturnStr = iniConfig.getVal("companion", "ip");
          if (keyReturnStr == null) {
            sendErrorCode("\"\\config.ini\"\n[companion] ip\nKEY NOT FOUND");
            return;
          }
          if (keyReturnStr.equals("")) {
            sendErrorCode("\"\\config.ini\"\n[companion] ip\nKEY NOT DECLARED");
            return;
          }
          companionIp = keyReturnStr;
        }
        { // port:
          keyReturnStr = iniConfig.getVal("companion", "port");
          if (keyReturnStr == null) {
            sendErrorCode("\"\\config.ini\"\n[companion] port\nKEY NOT FOUND");
            return;
          }
          if (keyReturnStr.equals("")) {
            sendErrorCode("\"\\config.ini\"\n[companion] port\nKEY NOT DECLARED");
            return;
          }
          if (!checkInt(keyReturnStr)) {
            sendErrorCode("\"\\config.ini\"\n[companion] port = \"" + keyReturnStr + "\"\nINVALID INT");
            return;
          }
          companionPort = int(keyReturnStr);
          if (companionPort > 65535 || companionPort < 0) {
            sendErrorCode("\"\\config.ini\"\n[companion] port = \"" + companionPort + "\"\nKEY OUT OF RANGE(0 - 65535)");
            return;
          }
        }
        { // Interval:
          keyReturnStr = iniConfig.getVal("companion", "interval");
          if (keyReturnStr == null) {
            sendErrorCode("\"\\config.ini\"\n[companion] interval\nKEY NOT FOUND");
            return;
          }
          if (keyReturnStr.equals("")) {
            sendErrorCode("\"\\config.ini\"\n[companion] interval\nKEY NOT DECLARED");
            return;
          }
          if (!checkInt(keyReturnStr)) {
            sendErrorCode("\"\\config.ini\"\n[companion] interval = \"" + keyReturnStr + "\"\nINVALID INT");
            return;
          }
          companionInterval = int(keyReturnStr);
          if (companionInterval < 100 && companionInterval != 0) {
            sendErrorCode("\"\\config.ini\"\n[companion] interval = \"" + companionInterval + "\"\nKEY OUT OF RANGE(>= 100)");
            return;
          }
        }
      }
    }

    // Clock:
    {
      for (int x = 0; x < numberOfClocks; x++) {
        { // General:
          { // StartUp:
            keyReturnStr = iniConfig.getVal("clock_general_" + (x + 1) + "", "startUp");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] startUp\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] startUp\nKEY NOT DECLARED");
              return;
            }
            if (keyReturnStr.equals("true")) {
              clockWindowManager[x].setVisible(true);
            } else if (keyReturnStr.equals("false")) {
              clockWindowManager[x].setVisible(false);
            } else if (keyReturnStr.equals("on")) {
              clockWindowManager[x].setVisible(true);
            } else if (keyReturnStr.equals("0ff")) {
              clockWindowManager[x].setVisible(false);
            } else {
              sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] startUp = \"" + keyReturnStr + "\"\nKEY MUST EQUAL: \"true\" or \"false\"");
              return;
            }
          }
          { // Screen:
            keyReturnStr = iniConfig.getVal("clock_general_" + (x + 1) + "", "screen");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] screen\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] screen\nKEY NOT DECLARED");
              return;
            }
            if (keyReturnStr.equals("auto")) {
              if (cache.fileBytes.length > x) {
                if (cache.fileBytes[x] < 1 || cache.fileBytes[x] > 10) {
                  cache.fileBytes[x] = 1;
                }
              } else {
                byte[] oldByte = new byte[cache.fileBytes.length];
                for (int y = 0; y < cache.fileBytes.length; y++) {
                  oldByte[y] = cache.fileBytes[y];
                }
                cache.fileBytes = new byte[x + 1];
                for (int y = 0; y < oldByte.length; y++) {
                  cache.fileBytes[y] = oldByte[y];
                }
                cache.fileBytes[x] = 1;
              }
              clockWindowManager[x].setScreen(cache.fileBytes[x]);
            } else {
              if (!checkInt(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] screen = \"" + keyReturnStr + "\"\nINVALID KEY");
                return;
              }
              if (int(keyReturnStr) < 1 || int(keyReturnStr) > 10) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] screen = \"" + companionPort + "\"\nKEY OUT OF RANGE(1 - 10)");
                return;
              }
              if (cache.fileBytes.length > x) {
                cache.fileBytes[x] = (byte)int(keyReturnStr);
              } else {
                byte[] oldByte = new byte[cache.fileBytes.length];
                for (int y = 0; y < cache.fileBytes.length; y++) {
                  oldByte[y] = cache.fileBytes[y];
                }
                cache.fileBytes = new byte[x + 1];
                for (int y = 0; y < oldByte.length; y++) {
                  cache.fileBytes[y] = oldByte[y];
                }
                cache.fileBytes[x] = (byte)int(keyReturnStr);
              }
              clockWindowManager[x].setScreen(int(keyReturnStr));
            }
          }
          { // BackgroundColor: *optional
            keyReturnStr = iniConfig.getVal("clock_general_" + (x + 1) + "", "background");
            if (keyReturnStr != null) {
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] background\nKEY NOT DECLARED");
                return;
              }
              keyReturnStr = keyReturnStr.replace("#", "");
              if (!checkHex(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] background = \"" + keyReturnStr + "\"\nINVALID HEX");
                return;
              }
              clockWindowManager[x].backGroundColor = unhex(keyReturnStr);
            }
          }
          { // TextColor: *optional
            keyReturnStr = iniConfig.getVal("clock_general_" + (x + 1) + "", "text");
            if (keyReturnStr != null) {
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] text\nKEY NOT DECLARED");
                return;
              }
              keyReturnStr = keyReturnStr.replace("#", "");
              if (!checkHex(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] text = \"" + keyReturnStr + "\"\nINVALID HEX");
                return;
              }
              clockWindowManager[x].textColor = unhex(keyReturnStr);
            }
          }
          { // ShadowOpactiy: *optional
            keyReturnStr = iniConfig.getVal("clock_general_" + (x + 1) + "", "shadowOpacity");
            if (keyReturnStr != null) {
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] shadowOpacity\nKEY NOT DECLARED");
                return;
              }
              keyReturnStr = keyReturnStr.replace("%", "");
              if (!checkInt(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] shadowOpacity = \"" + keyReturnStr + "\"\nINVALID INT");
                return;
              }
              if (int(keyReturnStr) < 0 || int(keyReturnStr) > 100) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] shadowOpacity = \"" + keyReturnStr + "\"\nKEY OUT OF RANGE(0% - 100%)");
                return;
              }
              clockWindowManager[x].shadowOpacity = int((float(keyReturnStr) / 100) * 255);
            }
          }
          { // Shadow_x: *optional
            keyReturnStr = iniConfig.getVal("clock_general_" + (x + 1) + "", "shadow_x");
            if (keyReturnStr != null) {
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] shadow_x\nKEY NOT DECLARED");
                return;
              }
              if (!checkInt(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] shadow_x = \"" + keyReturnStr + "\"\nINVALID INT");
                return;
              }
              clockWindowManager[0].shadowOffset_x = int(keyReturnStr);
            }
          }
          { // Shadow_y: *optional
            keyReturnStr = iniConfig.getVal("clock_general_" + (x + 1) + "", "shadow_y");
            if (keyReturnStr != null) {
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] shadow_y\nKEY NOT DECLARED");
                return;
              }
              if (!checkInt(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_general_" + (x + 1) + "] shadow_y = \"" + keyReturnStr + "\"\nINVALID INT");
                return;
              }
              clockWindowManager[0].shadowOffset_y = int(keyReturnStr);
            }
          }
        }

        { // Clock_Companion:
          { // Page: *only if "companionEnable"
            if (companionEnable) {
              keyReturnStr = iniConfig.getVal("clock_companion_" + (x + 1) + "", "page");
              if (keyReturnStr == null) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] page\nKEY NOT FOUND");
                return;
              }
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] page\nKEY NOT DECLARED");
                return;
              }
              if (!checkInt(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] page = \"" + keyReturnStr + "\"\nINVALID INT");
                return;
              }
              companionPage[x] = int(keyReturnStr);
              if (companionPage[x] < 1 || companionPage[x] > 99) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] page = \"" + keyReturnStr + "\"\nKEY OUT OF RANGE(1 - 99)");
                return;
              }
            }
          }
          { // Button: *only if "companionEnable"
            if (companionEnable) {
              keyReturnStr = iniConfig.getVal("clock_companion_" + (x + 1) + "", "button");
              if (keyReturnStr == null) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] button\nKEY NOT FOUND");
                return;
              }
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] button\nKEY NOT DECLARED");
                return;
              }
              if (!checkInt(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] button = \"" + keyReturnStr + "\"\nINVALID INT");
                return;
              }
              companionButton[x] = int(keyReturnStr);
              if (companionButton[x] < 1 || companionButton[x] > 32) {
                sendErrorCode("\"\\config.ini\"\n[clock_companion_" + (x + 1) + "] button = \"" + keyReturnStr + "\"\nKEY OUT OF RANGE(1 - 32)");
                return;
              }
            }
          }
        }

        { // UDP:
          { // EnableListen:
            keyReturnStr = iniConfig.getVal("clock_udp_" + (x + 1) + "", "enableListen");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_udp_" + (x + 1) + "] enableListen\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_udp_" + (x + 1) + "] enableListen\nKEY NOT DECLARED");
              return;
            }
            if (keyReturnStr.equals("true")) {
              clockWindowManager[x].udpListen(true);
            } else if (keyReturnStr.equals("false")) {
              clockWindowManager[x].udpListen(false);
            } else {
              sendErrorCode("\"\\config.ini\"\n[clock_udp_" + (x + 1) + "] enableListen = \"" + keyReturnStr + "\"\nKEY MUST EQUAL: \"true\" or \"false\"");
              return;
            }
          }
          { // Port: *only required if udp is listening
            if (clockWindowManager[x].udpIsListen()) {
              keyReturnStr = iniConfig.getVal("clock_udp_" + (x + 1) + "", "port");
              if (keyReturnStr == null) {
                sendErrorCode("\"\\config.ini\"\n[clock_udp_" + (x + 1) + "] port\nKEY NOT FOUND");
                return;
              }
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_udp_" + (x + 1) + "] port\nKEY NOT DECLARED");
                return;
              }
              if (!checkInt(keyReturnStr)) {
                sendErrorCode("\"\\config.ini\"\n[clock_udp_" + (x + 1) + "] port = \"" + keyReturnStr + "\"\nINVALID INT");
                return;
              }
              if (int(keyReturnStr) < 0 || int(keyReturnStr) > 65535) {
                sendErrorCode("\"\\config.ini\"\n[clock_udp_" + (x + 1) + "] port = \"" + keyReturnStr + "\"\nKEY OUT OF RANGE(0 - 65535)");
                return;
              }
              clockWindowManager[x].udpPort(int(keyReturnStr));
            }
          }
        }

        { // Time:
          { // Enable:
            keyReturnStr = iniConfig.getVal("clock_time_" + (x + 1) + "", "enable");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] enable\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] enable\nKEY NOT DECLARED");
              return;
            }
            if (keyReturnStr.equals("true")) {
              clockWindowManager[x].timeEnable = true;
            } else if (keyReturnStr.equals("false")) {
              clockWindowManager[x].timeEnable = false;
            } else {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] enable = \"" + keyReturnStr + "\"\nKEY MUST EQUAL: \"true\" or \"false\"");
              return;
            }
          }

          { // Font:
            String newFont;
            int newFontPt;
            keyReturnStr = iniConfig.getVal("clock_time_" + (x + 1) + "", "font");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] font\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] font\nKEY NOT DECLARED");
              return;
            }
            newFont = keyReturnStr;

            keyReturnStr = iniConfig.getVal("clock_time_" + (x + 1) + "", "size");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] size\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] size\nKEY NOT DECLARED");
              return;
            }
            if (!checkInt(keyReturnStr)) {
              sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] size = \"" + keyReturnStr + "\"\nINVALID INT");
              return;
            }
            newFontPt = int(keyReturnStr);
            clockWindowManager[x].clockFont_time = createFont(newFont, newFontPt);
          }
          if (clockWindowManager[x].timeEnable) {
            { // Offset_X: *optional
              keyReturnStr = iniConfig.getVal("clock_time_" + (x + 1) + "", "offset_x");
              if (keyReturnStr != null) {
                if (keyReturnStr.equals("")) {
                  sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] offset_x\nKEY NOT DECLARED");
                  return;
                }
                if (!checkInt(keyReturnStr)) {
                  sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] offset_x = \"" + keyReturnStr + "\"\nINVALID INT");
                  return;
                }
                clockWindowManager[x].timeOffset_X = int(keyReturnStr);
              }
            }
            { // Offset_Y: *optional
              keyReturnStr = iniConfig.getVal("clock_time_" + (x + 1) + "", "offset_y");
              if (keyReturnStr != null) {
                if (keyReturnStr.equals("")) {
                  sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] offset_y\nKEY NOT DECLARED");
                  return;
                }
                if (!checkInt(keyReturnStr)) {
                  sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] offset_y = \"" + keyReturnStr + "\"\nINVALID INT");
                  return;
                }
                clockWindowManager[x].timeOffset_Y = int(keyReturnStr);
              }
            }
            { // LeadingHourZero: *only required if "timeEnable"
              keyReturnStr = iniConfig.getVal("clock_time_" + (x + 1) + "", "leadingZero");
              if (keyReturnStr == null) {
                sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] leadingZero\nKEY NOT FOUND");
                return;
              }
              if (keyReturnStr.equals("")) {
                sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] leadingZero\nKEY NOT DECLARED");
                return;
              }
              if (keyReturnStr.equals("true")) {
                clockWindowManager[x].leadingHourZeroEnable = true;
              } else if (keyReturnStr.equals("false")) {
                clockWindowManager[x].leadingHourZeroEnable = false;
              } else {
                sendErrorCode("\"\\config.ini\"\n[clock_time_" + (x + 1) + "] enable = \"" + keyReturnStr + "\"\nKEY MUST EQUAL: \"true\" or \"false\"");
                return;
              }
            }
          }
        }

        { // Date:
          { // Enable:
            keyReturnStr = iniConfig.getVal("clock_date_" + (x + 1) + "", "enable");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] enable\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] enable\nKEY NOT DECLARED");
              return;
            }
            if (keyReturnStr.equals("true")) {
              clockWindowManager[x].dateEnable = true;
            } else if (keyReturnStr.equals("false")) {
              clockWindowManager[x].dateEnable = false;
            } else {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] enable = \"" + keyReturnStr + "\"\nKEY MUST EQUAL: \"true\" or \"false\"");
              return;
            }
          }
          { // Font:
            String newFont;
            int newFontPt;
            keyReturnStr = iniConfig.getVal("clock_date_" + (x + 1) + "", "font");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] font\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] font\nKEY NOT DECLARED");
              return;
            }
            newFont = keyReturnStr;

            keyReturnStr = iniConfig.getVal("clock_date_" + (x + 1) + "", "size");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] size\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] size\nKEY NOT DECLARED");
              return;
            }
            if (!checkInt(keyReturnStr)) {
              sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] size = \"" + keyReturnStr + "\"\nINVALID INT");
              return;
            }
            newFontPt = int(keyReturnStr);
            clockWindowManager[x].clockFont_date = createFont(newFont, newFontPt);
          }
          if (clockWindowManager[x].dateEnable) {
            { // Offset_X: *optional
              keyReturnStr = iniConfig.getVal("clock_date_" + (x + 1) + "", "offset_x");
              if (keyReturnStr != null) {
                if (keyReturnStr.equals("")) {
                  sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] offset_x\nKEY NOT DECLARED");
                  return;
                }
                if (!checkInt(keyReturnStr)) {
                  sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] offset_x = \"" + keyReturnStr + "\"\nINVALID INT");
                  return;
                }
                clockWindowManager[x].dateOffset_X = int(keyReturnStr);
              }
            }
            { // Offset_Y: *optional
              keyReturnStr = iniConfig.getVal("clock_date_" + (x + 1) + "", "offset_y");
              if (keyReturnStr != null) {
                if (keyReturnStr.equals("")) {
                  sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] offset_y\nKEY NOT DECLARED");
                  return;
                }
                if (!checkInt(keyReturnStr)) {
                  sendErrorCode("\"\\config.ini\"\n[clock_date_" + (x + 1) + "] offset_y = \"" + keyReturnStr + "\"\nINVALID INT");
                  return;
                }
                clockWindowManager[x].dateOffset_Y = int(keyReturnStr);
              }
            }
          }
        }

        { // ampm
          { // Enable:
            keyReturnStr = iniConfig.getVal("clock_ampm_" + (x + 1) + "", "enable");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] enable\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] enable\nKEY NOT DECLARED");
              return;
            }
            if (keyReturnStr.equals("true")) {
              clockWindowManager[x].ampmEnable = true;
            } else if (keyReturnStr.equals("false")) {
              clockWindowManager[x].ampmEnable = false;
            } else {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] enable = \"" + keyReturnStr + "\"\nKEY MUST EQUAL: \"true\" or \"false\"");
              return;
            }
          }
          { // Font:
            String newFont;
            int newFontPt;
            keyReturnStr = iniConfig.getVal("clock_ampm_" + (x + 1) + "", "font");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] font\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] font\nKEY NOT DECLARED");
              return;
            }
            newFont = keyReturnStr;

            keyReturnStr = iniConfig.getVal("clock_ampm_" + (x + 1) + "", "size");
            if (keyReturnStr == null) {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] size\nKEY NOT FOUND");
              return;
            }
            if (keyReturnStr.equals("")) {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] size\nKEY NOT DECLARED");
              return;
            }
            if (!checkInt(keyReturnStr)) {
              sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] size = \"" + keyReturnStr + "\"\nINVALID INT");
              return;
            }
            newFontPt = int(keyReturnStr);
            clockWindowManager[x].clockFont_ampm = createFont(newFont, newFontPt);
          }

          if (clockWindowManager[x].ampmEnable) {
            { // Offset_X: *optional
              keyReturnStr = iniConfig.getVal("clock_ampm_" + (x + 1) + "", "offset_x");
              if (keyReturnStr != null) {
                if (keyReturnStr.equals("")) {
                  sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] offset_x\nKEY NOT DECLARED");
                  return;
                }
                if (!checkInt(keyReturnStr)) {
                  sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] offset_x = \"" + keyReturnStr + "\"\nINVALID INT");
                  return;
                }
                clockWindowManager[x].ampmOffset_X = int(keyReturnStr);
              }
            }
            { // Offset_Y: *optional
              keyReturnStr = iniConfig.getVal("clock_ampm_" + (x + 1) + "", "offset_y");
              if (keyReturnStr != null) {
                if (keyReturnStr.equals("")) {
                  sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] offset_y\nKEY NOT DECLARED");
                  return;
                }
                if (!checkInt(keyReturnStr)) {
                  sendErrorCode("\"\\config.ini\"\n[clock_ampm_" + (x + 1) + "] offset_y = \"" + keyReturnStr + "\"\nINVALID INT");
                  return;
                }
                clockWindowManager[x].ampmOffset_Y = int(keyReturnStr);
              }
            }
          }
        }
      }
    }
  }
}

void draw() {
  if (!configError) {
    cache.run();
    companionRun();
    checkUdp();
    for (int x = 0; x < numberOfClocks; x++)
      clockWindowManager[x].run();
  }
}

void companionRun() {
  if (companionEnable) {
    boolean change = false;
    for (int x = 0; x < numberOfClocks; x++) {
      if (companionPreviousVisState[x] != clockWindowManager[x].isVisible())
        change = true;
      companionPreviousVisState[x] = clockWindowManager[x].isVisible();
    }

    if (change || (companionInterval > 0 && millis() - companionTimer >= companionInterval)) {
      companionTimer = millis();
      // send message to companion:
      {
        for (int x = 0; x < numberOfClocks; x++) {
          if (clockWindowManager[x].isVisible()) {
            String msg = "BANK-UP " + companionPage[x] + " " + companionButton[x];
            companionUdp.send(msg, companionIp, companionPort);
          } else {
            String msg = "BANK-DOWN " + companionPage[x] + " " + companionButton[x];
            companionUdp.send(msg, companionIp, companionPort);
          }
        }
      }
    }
  }
}

void checkUdp() {
  for (int x = 0; x < numberOfClocks; x++) {
    if (clockWindowManager[x].udpError()) {
      sendErrorCode("UDP ERROR\n[clock_udp_" + (x + 1) + "] port\nPORT BUSY");
      return;
    }
  }
}

class FileCache {
  private String _fileName;
  private byte[] _prevBytes;
  private int _writeTimer = 0;

  byte[] fileBytes; // use this array to read and write to file

  private final int _writeInterval = 3000;  // write every 5s

  FileCache(String fileName) {
    _fileName = fileName;
    fileBytes = loadBytes(fileName);
    if (fileBytes == null)
      fileBytes = new byte[0];
    _cpyBytes();
  }

  void run() {
    if (millis() - _writeTimer >= _writeInterval) {
      _writeTimer = millis();
      if (fileBytes == null)
        fileBytes = new byte[0];
      boolean change = false;
      if (fileBytes.length != _prevBytes.length)
        change = true;
      else {
        for (int x = 0; x < fileBytes.length && !change; x++) {
          if (fileBytes[x] != _prevBytes[x])
            change = true;
        }
      }

      if (change) {
        saveBytes(_fileName, fileBytes);
        _cpyBytes();
      }
    }
  }

  private void _cpyBytes() {  // copy all contents(including size) from "fileBytes" to "_prevFileBytes"
    _prevBytes = new byte[fileBytes.length];
    for (int x = 0; x < fileBytes.length; x++)
      _prevBytes[x] = fileBytes[x];
  }
}

public class ClockWindowManager {
  private GraphicsEnvironment GraphicsDevices = GraphicsEnvironment.getLocalGraphicsEnvironment();
  private UDP _udp;

  private ClockWindow _clockWin;
  private int _managerId;
  private int _screenNum = 1;
  private boolean _visibility = false;
  private boolean _exit = false;

  private boolean _udpListen = false;

  //clock vars:
  //public fonts. these NEED to be set before running clock
  PFont clockFont_date;
  PFont clockFont_ampm;
  PFont clockFont_time;

  boolean timeEnable = true;
  boolean dateEnable = true;
  boolean ampmEnable = true;

  boolean leadingHourZeroEnable = false;

  int timeOffset_X = 0;
  int timeOffset_Y = 0;

  int dateOffset_X = 0;
  int dateOffset_Y = 0;

  int ampmOffset_X = 0;
  int ampmOffset_Y = 0;

  int shadowOffset_x = 0;
  int shadowOffset_y = 0;

  int shadowOpacity = 0;  // (0 - 255) 0 = (clear)

  int backGroundColor = 0;
  int textColor = 255;

  ClockWindowManager() {
    _exit = true;
  }

  ClockWindowManager(int screenNum) {
    if (screenNum > 0 && screenNum <= 10)
      _screenNum = screenNum;
    else
      _screenNum = 1;
  }

  ClockWindowManager(int screenNum, boolean visibility) {
    if (screenNum > 0 && screenNum <= 10)
      _screenNum = screenNum;
    else
      _screenNum = 1;
    _visibility = visibility;
  }

  void udpListen(boolean listen) {
    _udpListen = listen;
    if (_udp != null)
      _udp.listen(_udpListen);
  }

  boolean udpIsListen() {
    return _udpListen;
  }

  void udpPort(int port) {
    _udp = new UDP(this, port);
    _udp.listen(_udpListen);
  }

  boolean udpError() {
    if (_udp != null) {
      if (_udp.port() == -1)
        return true;
    }
    return false;
  }

  void restart() {
    _exit = false;
    if (_clockWin != null) {
      _clockWin.exit();
      _clockWin = null;
    }
  }

  void setVisible(boolean vis) {
    _visibility = vis;
  }

  boolean isVisible() {
    return _visibility;
  }

  void setScreen(int screenNum) {
    _exit = false;
    if (screenNum > 0 && screenNum <= 10)
      _screenNum = screenNum;
    else
      _screenNum = 1;
    if (_clockWin != null) {
      _clockWin.exit();
      _clockWin = null;
    }
  }

  // run as needed. only used to check available screens and run clock render or disable it
  void run() {
    if (!_exit) {  // taken from globalVar
      if (GraphicsDevices.getScreenDevices().length >= _screenNum) {
        if (_visibility) {
          if (_clockWin == null) {
            _clockWin = new ClockWindow(_screenNum, this);
          }
          _clockWin.setVisible(true);
        } else {
          if (_clockWin == null) {
            _clockWin = new ClockWindow(_screenNum, this);
          }
          _clockWin.setVisible(false);
        }
      } else {
        if (_clockWin != null) {
          _clockWin.exit();
          _clockWin = null;
        }
      }
    } else {
      if (_clockWin != null) {
        _clockWin.exit();
        _clockWin = null;
      }
    }
  }

  void receive(byte[] data) {
    if (_udpListen) {
      /*
      visible: on/off/true/false/toggle
       screen: SCRN_NUM/cycle
       restart
       exit
       */
      String msg = new String(data);
      msg = msg.toLowerCase();

      if (msg.indexOf("visible") == 0) {
        msg = msg.replace("visible", "");
        msg = msg.replace(" ", "");
        msg = msg.replace("\t", "");
        msg = msg.replace("\n", "");
        msg = msg.replace("\r", "");

        if (msg.equals("on")) {
        } else if (msg.equals("off")) {
        } else if (msg.equals("toggle")) {
        }
      } else if (msg.indexOf("screen") == 0) {
        msg = msg.replace("screen", "");
        msg = msg.replace(" ", "");
        msg = msg.replace("\t", "");
        msg = msg.replace("\n", "");
        msg = msg.replace("\r", "");

        if (msg.equals("cycle")) {
          _screenNum++;
          if (_screenNum > GraphicsDevices.getScreenDevices().length) {
            _screenNum = 1;
          }
        } else if (checkInt(msg)) {
          setScreen(int(msg));
        }
      } else if (msg.indexOf("restart") == 0) {
        msg = msg.replace(" ", "");
        msg = msg.replace("\t", "");
        msg = msg.replace("\n", "");
        msg = msg.replace("\r", "");
        if (msg.equals("restart")) {
          restart();
        }
      } else if (msg.indexOf("exit") == 0) {
        msg = msg.replace(" ", "");
        msg = msg.replace("\t", "");
        msg = msg.replace("\n", "");
        msg = msg.replace("\r", "");
        if (msg.equals("exit")) {
          runExit();
        }
      }
    }
  }

  void exit() {
    if (_clockWin != null) {
      _clockWin.exit();
      _clockWin = null;
    }
    if (_udp != null) {
      _udp.listen(false);
      _udp.close();
    }
    _udpListen = false;
    _exit = true;
  }
}


class ClockWindow extends PApplet {

  private int _screenNum;
  private boolean _vis = false;

  //varsto keep track of date and time:
  private int _monthInt;
  private int _dayInt;
  private int _yearInt;

  private int _hourInt;
  private int _minuteInt;
  private int _secondInt;

  // final absolutes(only for development):
  private final int _absPositionOffset_X = 0;
  private final int _absPositionOffset_Y = -11;

  // manager obj to pull vals from:
  private ClockWindowManager _clockWinManagerObj;

  ClockWindow(int screenNum, ClockWindowManager clockWinManagerObj) {
    super();
    _screenNum = screenNum;
    _clockWinManagerObj = clockWinManagerObj;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    fullScreen(_screenNum);
  }

  void setup() {
    surface.setAlwaysOnTop(true);
    surface.setVisible(false);
    noCursor();
  }

  void draw() {
    if (_vis)
    {
      //reset background:
      background(_clockWinManagerObj.backGroundColor);

      _updateCalendarValues();
      _drawDateTime();
    }
  }

  void setVisible(boolean vis) {
    _vis = vis;
    if (_vis)
      redraw();
    surface.setVisible(_vis);
  }

  boolean isVisible() {
    return _vis;
  }

  void exit() {
    _vis = false;
    surface.setVisible(false);
  }

  private void _updateCalendarValues() {
    _monthInt = month();
    _dayInt = day();
    _yearInt = year();
    _hourInt = hour();
    _minuteInt = minute();
    _secondInt = second();
  }


  private void _drawDateTime() {
    String yearStr = str(_yearInt);
    String dayStr = str(_dayInt);

    String dayOfTheWeek = "";
    String monthStr = "";

    switch(Calendar.getInstance().get(Calendar.DAY_OF_WEEK)) {
    case 1:
      dayOfTheWeek = "SUNDAY";
      break;
    case 2:
      dayOfTheWeek = "MONDAY";
      break;
    case 3:
      dayOfTheWeek = "TUESDAY";
      break;
    case 4:
      dayOfTheWeek = "WEDNESDAY";
      break;
    case 5:
      dayOfTheWeek = "THURSDAY";
      break;
    case 6:
      dayOfTheWeek = "FRIDAY";
      break;
    case 7:
      dayOfTheWeek = "SATURDAY";
      break;
    };

    switch(_monthInt) {
    case 1:
      monthStr = "JANUARY";
      break;
    case 2:
      monthStr = "FEBRUARY";
      break;
    case 3:
      monthStr = "MARCH";
      break;
    case 4:
      monthStr = "APRIL";
      break;
    case 5:
      monthStr = "MAY";
      break;
    case 6:
      monthStr = "JUNE";
      break;
    case 7:
      monthStr = "JULY";
      break;
    case 8:
      monthStr = "AUGUST";
      break;
    case 9:
      monthStr = "SEPTEMBER";
      break;
    case 10:
      monthStr = "OCTOBER";
      break;
    case 11:
      monthStr = "NOVEMBER";
      break;
    case 12:
      monthStr = "DECEMBER";
      break;
    };

    String dateFullStr = dayOfTheWeek + ", " + monthStr + " " + dayStr + ", " + yearStr;

    /*---------------------------------------------------------- */

    String AM_PM = "";
    if (_hourInt >= 12) {
      AM_PM = "PM";
      if (_hourInt != 12)
        _hourInt -= 12;
    } else {
      AM_PM = "AM";
      if (_hourInt == 0)
        _hourInt = 12;
    }

    String hourStr = str(_hourInt);
    String minuteStr = str(_minuteInt);
    String leadingMinuteZero = "";
    String leadingHourZero = "";
    if (_clockWinManagerObj.leadingHourZeroEnable && _hourInt < 10) leadingHourZero = "0";
    if (_minuteInt < 10) leadingMinuteZero = "0";

    String timeFullStr = leadingHourZero + hourStr + ":" + leadingMinuteZero + minuteStr;

    textFont(_clockWinManagerObj.clockFont_date);
    float dateFullStrWidth = textWidth(dateFullStr);
    float dateFullStrAscent = textAscent() * 0.4;
    float dateFullStrDescent = -textDescent() * 2.02;


    textFont(_clockWinManagerObj.clockFont_ampm);
    float AM_PM_width = textWidth(AM_PM);
    float AM_PM_Ascent = textAscent() * 0.4;
    float AM_PM_Descent = -textDescent() * 2.02;
    float AM_PM_Height = AM_PM_Ascent + AM_PM_Descent;


    textFont(_clockWinManagerObj.clockFont_time);
    float timeFullStrWidth = textWidth(timeFullStr);
    float timeFullStrAscent = textAscent() * 0.4;
    float timeFullStrDescent = -textDescent() * 2.02;
    float timeFullStrHeight = timeFullStrAscent + timeFullStrDescent;

    stroke(255);
    //line(0, height / 2, width, height / 2);
    //line(0,(height / 2) - timeFullStrAscent, width,(height / 2) - timeFullStrAscent);
    //line(0,(height / 2) + timeFullStrDescent, width,(height / 2) + timeFullStrDescent);


    fill(0, _clockWinManagerObj.shadowOpacity);


    textFont(_clockWinManagerObj.clockFont_date);
    textAlign(CENTER, CENTER);
    if (_clockWinManagerObj.dateEnable)
      text(dateFullStr, (width / 2) + _absPositionOffset_X + _clockWinManagerObj.dateOffset_X + _clockWinManagerObj.shadowOffset_x,
        (height / 2) + timeFullStrDescent + dateFullStrDescent + 33 + _absPositionOffset_Y + _clockWinManagerObj.dateOffset_Y + _clockWinManagerObj.shadowOffset_y);

    textFont(_clockWinManagerObj.clockFont_ampm);
    textAlign(CENTER, CENTER);
    if (_clockWinManagerObj.ampmEnable)
      text(AM_PM, (width / 2) + (timeFullStrWidth / 2) + (AM_PM_width / 2) + 10 + _absPositionOffset_X + _clockWinManagerObj.ampmOffset_X + _clockWinManagerObj.shadowOffset_x,
        (height / 2) + timeFullStrDescent - (AM_PM_Descent) + _absPositionOffset_Y + _clockWinManagerObj.ampmOffset_Y + _clockWinManagerObj.shadowOffset_y);

    textFont(_clockWinManagerObj.clockFont_time);
    textAlign(CENTER, CENTER);
    if (_clockWinManagerObj.timeEnable)
      text(timeFullStr, (width / 2) + _absPositionOffset_X + _clockWinManagerObj.timeOffset_X + _clockWinManagerObj.shadowOffset_x,
        (height / 2) + _absPositionOffset_Y + _clockWinManagerObj.timeOffset_Y + _clockWinManagerObj.shadowOffset_y);




    fill(_clockWinManagerObj.textColor);

    textFont(_clockWinManagerObj.clockFont_date);
    textAlign(CENTER, CENTER);
    if (_clockWinManagerObj.dateEnable)
      text(dateFullStr, (width / 2) + _absPositionOffset_X + _clockWinManagerObj.dateOffset_X,
        (height / 2) + timeFullStrDescent + dateFullStrDescent + 33 + _absPositionOffset_Y + _clockWinManagerObj.dateOffset_Y);

    textFont(_clockWinManagerObj.clockFont_ampm);
    textAlign(CENTER, CENTER);
    if (_clockWinManagerObj.ampmEnable)
      text(AM_PM, (width / 2) + (timeFullStrWidth / 2) + (AM_PM_width / 2) + 10 + _absPositionOffset_X + _clockWinManagerObj.ampmOffset_X,
        (height / 2) + timeFullStrDescent - (AM_PM_Descent) + _absPositionOffset_Y + _clockWinManagerObj.ampmOffset_Y);

    textFont(_clockWinManagerObj.clockFont_time);
    textAlign(CENTER, CENTER);
    if (_clockWinManagerObj.timeEnable)
      text(timeFullStr, (width / 2) + _absPositionOffset_X + _clockWinManagerObj.timeOffset_X,
        (height / 2) + _absPositionOffset_Y + _clockWinManagerObj.timeOffset_Y);
  }

  void keyPressed() { // ignore escape key
    if (key == ESC) {
      key = 0;
      runExit();  // this is only for development purposes
    }
  }
}

class ErrorScreenWindow extends PApplet {

  String _errorMessage = null;
  String _errorCode = null;

  ErrorScreenWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  ErrorScreenWindow(String errorMessage) {
    super();
    _errorMessage = errorMessage;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  ErrorScreenWindow(String errorMessage, String errorCode) {
    super();
    _errorMessage = errorMessage;
    _errorCode = errorCode;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(500, 300);
  }

  void setup() {
    surface.setLocation(100, 100);
    if (_errorCode != null)
      surface.setTitle(_errorCode);
    else
      surface.setTitle("ERROR");

    if (_errorMessage != null)
    {
      background(0, 0, 0);
      textFont(createFont("Arial", 60));
      textAlign(CENTER, CENTER);
      fill(255, 0, 0);
      text("ERROR", width / 2, 100);

      int textFontSize = 25;
      textFont(createFont("Arial", textFontSize));
      while (textFontSize > 1 && textWidth(_errorMessage) > width)
        textFont(createFont("Arial", --textFontSize));
      //textFont(createFont("Arial", 25));
      textAlign(CENTER, CENTER);
      textLeading(40);
      fill(255, 255, 255);
      text(_errorMessage, width / 2, (height / 2) + (height / 8));
    } else {
      background(0, 0, 0);
      textFont(createFont("Arial", 60));
      textAlign(CENTER, CENTER);
      fill(255, 0, 0);
      text("ERROR", width / 2, 100);

      textFont(createFont("Arial", 25));
      textAlign(CENTER, CENTER);
      textLeading(40);
      fill(255, 255, 255);
      text("UNKNOWN", width / 2, (height / 2) + (height / 4) - (height / 16));
    }
    surface.setAlwaysOnTop(true);
    noLoop();
  }

  void mousePressed() {
    exit();
  }
}

void sendErrorCode() {
  noLoop();
  if (clockWindowManager != null)
    for (int x = 0; x < numberOfClocks; x++) {
      if (clockWindowManager[x] != null)
        clockWindowManager[x].exit();
    }
  ErrorScreenWindow errorScreen = new ErrorScreenWindow();
  configError = true;
}

void sendErrorCode(String errorString) {
  noLoop();
  if (clockWindowManager != null)
    for (int x = 0; x < numberOfClocks; x++) {
      if (clockWindowManager[x] != null)
        clockWindowManager[x].exit();
    }
  ErrorScreenWindow errorScreen = new ErrorScreenWindow(errorString);
  configError = true;
}

void sendErrorCode(String errorString, String errorTitle) {
  noLoop();
  if (clockWindowManager != null)
    for (int x = 0; x < numberOfClocks; x++) {
      if (clockWindowManager[x] != null)
        clockWindowManager[x].exit();
    }
  ErrorScreenWindow errorScreen = new ErrorScreenWindow(errorString, errorTitle);
  configError = true;
}

void runExit() {
  exit();
}

boolean checkHex(String hexIn) {
  for (int x = 0; x < (hexIn.length()); x++) {
    if ((hexIn.charAt(x) >= 'a' && hexIn.charAt(x) <= 'f') || (hexIn.charAt(x) >= 'A' && hexIn.charAt(x) <= 'F') || (hexIn.charAt(x) >= '0' && hexIn.charAt(x) <= '9'));
    else
      return false;
  }
  return true;
}

boolean checkInt(String intIn) {
  for (int x = 0; x < (intIn.length()); x++) {
    if ((intIn.charAt(x) >= '0' && intIn.charAt(x) <= '9') || intIn.charAt(x) == '-' || intIn.charAt(x) == '+');
    else
      return false;
  }
  return true;
}
