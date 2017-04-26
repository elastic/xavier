/**
 * @author       Kunal Vikram Singh
 * @date         March 2017
 * @description  This is a Utility Class
 *               for establishing a connection
 *               between Elasticsearch and SFDC
 */

public without sharing class Sf_Es_Connector {
  
  /* default timeout is 10000 this has been set to 90K
   * so we want to give apex max bandwidth possible to process
   * GET would usually be milliseconds anyway this is best for 
   * POST requests
   */
  public static Integer MAX_TIMEOUT = 90000;
  
  
  /**
   * @description Build the Http getRequest to get ES Response
   * @inputs
   *     1. String uniqueName = uniqueName field value on ES 
   *                            Connector Object to get the query
   *     2. String searchTerm = String that we are using in ES Search
   *
   */
  public static HttpRequest buildGetRequest (String uniqueName, String searchTerm) {
    Map <Integer , String> param = new Map <Integer, String> ();
    param.put(0,searchTerm);
    return (buildGetRequest(uniqueName, param));
    
  }

  /**
   * @description Build the Http getRequest to get ES Response if multiple search Terms exist
   * @inputs
   *     1. String uniqueName = uniqueName field value on ES 
   *                            Connector Object to get the query
   *     2. MapMap <Integer, String> searchTermMap = ex. {<0, search1>, <1, search1>}
   *                            The idea is to have a map of search terms against int
   *                            So searchTerms in ES Connector can be splitted in same 
   *                            order.
   *
   */
  public static HttpRequest buildGetRequest (String uniqueName, Map <Integer, String> searchTermmap) {
    try{
      HttpRequest esGet = new HttpRequest ();
      String body;
      ES_Connector__c es = [SELECT Id,
                                   Name, 
                                   Is_Active__c,
                                   Endpoint__c,
                                   Password__c,
                                   Body__c,
                                   Search_Term__c,
                                   Unique_Record_Name__c,
                                   Username__c
                            FROM ES_Connector__c
                            WHERE Unique_Record_Name__c =:uniqueName];
      if (es != null && es.Is_Active__c) {
        esGet.setEndpoint(es.Endpoint__c);
        esGet.setHeader('Authorization',getAuthHead(es.Username__c, es.Password__c));
        esGet.setBody( getBodyStr(es.Body__c,searchTermMap, es.Search_Term__c));
        esGet.setMethod('GET');
        esGet.setTimeout(MAX_TIMEOUT);
      
      } else {
        esGet = null;
      }    
      return esGet;
    } catch (Exception e) {
      return null;
    }
  }
  
  /**
   * @description build authorization header
   */
  public static String getAuthHead(String uname, String pwd) {
    Blob headerValue = Blob.valueOf( uname +':' +pwd);
    return('Basic ' + EncodingUtil.base64Encode(headerValue));  
  }

  /**
   * @description build get Request Body
   * @inputs
   *     1. String body = Body of the Query from the Connector Object
   *     2. String searchTerm = string that needs to be queried                      
   *     3. String searchParamToReplace = the raw searchParam in query that
   *                                      needs replacement
   */
  public static String getBodyStr(String body, String searchTerm,
                                      String searchParamToReplace) {
    if (searchTerm.contains('"')) {
      searchTerm = searchTerm.replaceAll('"', '');
    }
    if (body.contains(searchParamToReplace)) {
      body = body.replaceAll(searchParamToReplace,searchTerm );
    }
    return body;
  }

  /**
   * @description build get Request Body
   * @inputs
   *     1. String body = Body of the Query from the Connector Object
   *     2. String searchParamToReplace = the raw searchParam in query that
   *                                      needs replacement
   *     3. MapMap <Integer, String> searchTermMap = ex. {<0, search0>, <1, search1>}
   *                            The idea is to have a map of search terms against int
   *                            So searchTerms in ES Connector can be splitted in same 
   *                            order.

   */
  public static String getBodyStr(String body, Map <Integer, String> searchTermMap,
                                      String searchParamToReplace) {
    List <String> searchParamsToReplace = searchParamToReplace.split('\\|');
    for (Integer i = 0; i < searchTermMap.size(); i++) {
      String termToReplace = searchParamsToReplace.get(i);
      String actualTerm = searchTermMap.get(i);
      body = getBodyStr(body,actualTerm, termToReplace );
    }
    return body;
  }

  /**
   * @description This method takes in HttpRequest as an Arg 
   *              and returns the response string after normalization
   */
  
  public static String getResponseString (HttpRequest req) {
    try {
      Http h = new Http();
      HttpResponse res = h.send(req);
      String responseStr = res.getBody();
      if (responseStr.contains('_source')) {
        responseStr = responseStr.replaceAll('_source' , 'source_x'); 
      }
      return responseStr;
    } catch (Exception e) {
      return null;
    }
  }

}

