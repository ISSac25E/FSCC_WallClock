// Version 2.0

public class IniParse {
  private String _fileName;
  private boolean _fileExists;
  public IniParse(String fileName) {
    _fileName = fileName;
    byte[] fileBytes = loadBytes(_fileName);
    if(fileBytes == null) _fileExists = false;
    else  _fileExists = true;
  }
  
  public boolean exists() {
    return _fileExists;
  }
  
  public String getVal(String section, String key) {
    if (_fileExists)
    {
      BufferedReader reader = createReader(_fileName);
      String readNewLine = null;
      boolean sectionFound = false;
      if (section.equals("")) sectionFound = true;
      try {
        while((readNewLine = reader.readLine()) != null) {
          //first rulle out comments within ini file:
          readNewLine = _iniNullComment(readNewLine);
          //continue only if something is left over:
          if (sectionFound) {
            if (readNewLine.indexOf("[") != -1 || readNewLine.indexOf("]") != -1)
            {
              sectionFound = false;
              if (readNewLine.indexOf("[") != -1 && readNewLine.indexOf("]") != -1 && 
                readNewLine.indexOf("]") > readNewLine.indexOf("[")) {
                //another potential section found
                boolean sectionFalse = false; // << reset section find
                for (int x = 0; x < readNewLine.indexOf("[") && !sectionFalse; x++) {
                  if (readNewLine.charAt(x) != ' ' && readNewLine.charAt(x) != '\t')
                    sectionFalse = true;
                }
                for (int x = readNewLine.length() - 1; x > readNewLine.indexOf("]") && sectionFalse; x--) {
                  if (readNewLine.charAt(x) != ' ' && readNewLine.charAt(x) != '\t')
                    sectionFalse = true;
                }
                if (!sectionFalse) {
                  //found a section
                  String newSection = readNewLine.substring(readNewLine.indexOf("[") + 1, readNewLine.indexOf("]"));
                  if (section.equals(newSection)) {
                    //section has been found:
                    sectionFound = true;
                  }
                }
              }
            } else {
              if (readNewLine.indexOf('=') != -1) {
                String[] splitEqualSign = split(readNewLine, '=');
                if (splitEqualSign.length == 2) // << must be 2(left of equals sign and right)
                {
                  int index_0 = 0;
                  int index_1 = splitEqualSign[0].length() - 1;
                  while(index_0 < index_1 && (splitEqualSign[0].charAt(index_0) == ' ' || splitEqualSign[0].charAt(index_0) == '\t'))
                    index_0++;
                  while(index_1 > index_0 && (splitEqualSign[0].charAt(index_1) == ' ' || splitEqualSign[0].charAt(index_1) == '\t'))
                    index_1--;
                  splitEqualSign[0] = splitEqualSign[0].substring(index_0, index_1 + 1);
                  if (splitEqualSign[0].equals(" "))
                    splitEqualSign[0] = "";
                  
                  if (splitEqualSign[0].equals(key)) {
                    index_0 = 0;
                    index_1 = splitEqualSign[1].length() - 1;
                    while(index_0 < index_1 && (splitEqualSign[1].charAt(index_0) == ' ' || splitEqualSign[1].charAt(index_0) == '\t'))
                      index_0++;
                    while(index_1 > index_0 && (splitEqualSign[1].charAt(index_1) == ' ' || splitEqualSign[1].charAt(index_1) == '\t'))
                      index_1--;
                    splitEqualSign[1] = splitEqualSign[1].substring(index_0, index_1 + 1);
                    //if (splitEqualSign[1].equals(" "))
                    //return "";
                    //else 
                    return splitEqualSign[1];
                  }
                  
                }
              }
              else {
                int index_0 = 0;
                int index_1 = readNewLine.length() - 1;
                while(index_0 < index_1 && (readNewLine.charAt(index_0) == ' ' || readNewLine.charAt(index_0) == '\t'))
                  index_0++;
                while(index_1 > index_0 && (readNewLine.charAt(index_1) == ' ' || readNewLine.charAt(index_1) == '\t'))
                  index_1--;
                readNewLine = readNewLine.substring(index_0, index_1 + 1);
                if (readNewLine.equals(" "))
                  readNewLine = "";
                if (readNewLine.equals(key)) {
                  return "";
                }
              }
            }
          } else {
            if (readNewLine.indexOf("[") != -1 && readNewLine.indexOf("]") != -1 && 
              readNewLine.indexOf("]") > readNewLine.indexOf("[")) {
              boolean sectionFalse = false;
              for (int x = 0; x < readNewLine.indexOf("[") && !sectionFalse; x++) {
                if (readNewLine.charAt(x) != ' ' && readNewLine.charAt(x) != '\t')
                  sectionFalse = true;
              }
              for (int x = readNewLine.length() - 1; x > readNewLine.indexOf("]") && sectionFalse; x--) {
                if (readNewLine.charAt(x) != ' ' && readNewLine.charAt(x) != '\t')
                  sectionFalse = true;
              }
              if (!sectionFalse) {
                //found a section
                String newSection = readNewLine.substring(readNewLine.indexOf("[") + 1, readNewLine.indexOf("]"));
                if (section.equals(newSection)) {
                  //section has been found:
                  sectionFound = true;
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
    }
    return null;
  }
  
  private String _iniNullComment(String readString) {
    String[] newString_0 = split(readString, ";");
    if (newString_0.length > 0) {
      String[] newString_1 = split(newString_0[0], "#");
      if (newString_1.length > 0)
        return newString_1[0];
      else
        return "";
    } else
      return "";
  }
}
