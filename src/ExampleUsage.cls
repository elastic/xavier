public class ExampleUsage {
 
  /**
   * @description This method will be used when we need to search 
   *              Single Search String.
   */
 
 // This is your text to search may be an inputText on Visualforce
  public String searchStr {get; set;}   
 
 public String getSearchItemsSingleSearch (){
    String responseStr;
    // Unique Record Name field Value On ES Connector 
    String unique_record_name = 'my_demo'; 
    HttpRequest req = Sf_Es_Connector.buildGetRequest( unique_record_name , searchStr);
    if (req != null) {
      responseStr =   Sf_Es_Connector.getResponseString(req);
    }
    return response;
  }
  
  /**
   * @description This method will be used when we need to search 
   *              Multiple Strings may be on Multiple Fields
   */

  // These are your search strings may be an inputText on Visualforce
  public String searchStr1 {get; set;} 
  public String searchStr2 {get; set;} 

  public String getSearchItemsMultipleSearch (){
    String responseStr;
    Map <Integer, String> params = new Map <Integer, String> ();
    // Unique Record Name field Value On ES Connector 
    String unique_record_name = 'my_demo'; 
    // Build a Map of Integer and String to pass to get Request
    params.put(0,searchStr1);
    params.put(1,searchStr2);
    // Note searchStr1 will replace search1 in query and searchStr2 will replace search2
    HttpRequest req = Sf_Es_Connector.buildGetRequest( unique_record_name , params);
    if (req != null) {
      responseStr =   Sf_Es_Connector.getResponseString(req);
    }
    return response;
  }

  /**
   * @description Entire Response Object of es response
   *              It is a an outer hit which has list of 
   *              Inner Hits and every inner hit has a source
   */

  public class EntireObj {
    public outerHit hits;
  }
  
  /**
   * @description Outer hit of es response
   *              It is a List of Inner Hits
   */
  
  public Class outerHit {
    public List <individualHit> hits;
  }
  
  /**
   * @description Inner hit of es response
   */
  public Class individualHit {
    public individualSource source_x;
  }  
  
  /**
   * @ description  Source Class to parse the
   *                ES Response inner hit source
   *                which has fields body of record
   */
  public Class individualSource {
    public String id;
    public String field1;
    public String field2;
  
  }

}
