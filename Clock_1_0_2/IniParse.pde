public class IniParse {
  private String _fileName;
  public IniParse(String fileName) {
    _fileName = fileName;
  }

  public String getVal(String section, String key) {
    BufferedReader reader = createReader(_fileName);
    String readNewLine = null;
    boolean sectionFound = false;
    if (section.equals("")) sectionFound = true;
    try {
      while ((readNewLine = reader.readLine()) != null) {
        // first rulle out comments within ini file:
        String[] newLine_0 = split(readNewLine, ";");
        if (newLine_0.length > 0)
        {
          String[] newLine_1 = split(newLine_0[0], "#");
          if (newLine_1.length > 0) {
            // continue only if something is left over:
            if (sectionFound) {
              if (newLine_1[0].indexOf("[") != -1 && newLine_1[0].indexOf("]") != -1 &&
                newLine_1[0].indexOf("]") > newLine_1[0].indexOf("[")) {
                // another potential section found
                sectionFound = false; // reset section found
                String newSection = newLine_1[0].substring(newLine_1[0].indexOf("[") + 1, newLine_1[0].indexOf("]"));
                if (section.equals(newSection)) {
                  // section has been found:
                  sectionFound = true;
                }
              } else {
                String[] newLineSplitBlankSpace = splitTokens(newLine_1[0]);
                if (newLineSplitBlankSpace.length > 0) {
                  if (newLineSplitBlankSpace[0].equals(key)) {
                    if (newLineSplitBlankSpace.length > 2 &&
                      newLineSplitBlankSpace[1].equals("=")) {
                      char firstValidChar = newLineSplitBlankSpace[2].charAt(0);
                      return newLine_1[0].substring(newLine_1[0].indexOf(firstValidChar, newLine_1[0].indexOf("=")));
                    }
                    return "";
                  }
                }
              }
            } else {
              if (newLine_1[0].indexOf("[") != -1 && newLine_1[0].indexOf("]") != -1 &&
                newLine_1[0].indexOf("]") > newLine_1[0].indexOf("[")) {
                //found a section
                String newSection = newLine_1[0].substring(newLine_1[0].indexOf("[") + 1, newLine_1[0].indexOf("]"));
                if (section.equals(newSection)) {
                  //section has been found:
                  sectionFound = true;
                }
              }
            }
          }
        }
      }
      reader.close();
    }
    catch(IOException e) {
      e.printStackTrace();
    }
    return null;
  }
}
