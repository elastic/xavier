# Xavier Documentation
This document explains the usage of Xavier -- a Salesforce + Elastic Stack connector.
<br/>
## 1.0 Overview of Key Salesforce Components 
* Remote Site Setup
* Create ES Connector Object
* Create Sf_ES_Connector APEX class

## 2.0 Setup Step-By-Step Instructions

### 2.1 Remote Site Setup
Setup a remote site setting for callout where endpoint should be the endpoint of your cluster with port number.

### 2.2 ES Connector Object
Create a new custom object called ```ES Connector``` with following fields:

Name  | Type | Description
------ | ------------- | ------- 
Body | Long Text Area(131072) | The JSON body for your search query
Endpoint | Text(255) | Remote host/endpoint to connect
Username | Text(255) | Security/Shield Username 
Password | Text(255) | Security/Shield Password (We recommend limiting access via Field Level Security in your org.)
Search Term | Text(255) | Placeholder Search Term to be replaced by search term in your Use Case. Separate multiple terms with a pipe ("\|"). 
Unique Record Name | Text(255) (Unique Case Insensitive) | This is indexed field will be used in SOQL for retrieving this record

### 2.3 Create Sf_ES_Connector class
Here a <a href="https://github.com/elastic/xavier/blob/master/src/Sf_Es_Connector.cls" target="_blank">link</a> to the source of our sample implementation.

## 3.0 Framework Usage
We can use this framework to fetch data from Elasticsearch. Below is a walkthrough of how to 
use it for a single search term and also searching multiple terms in Elasticsearch.

### 3.1 Single Search Term Query

Write a Elasticsearch query to search your desired index/types/etc. 
```
GET my_demo_index/_search
{
  "size": 10,
  "query" : {
    "match_phrase" : {
      "DEMO_FIELD": "###SearchTerm###"
    }
  }
}
```

Copy the query and create a record in Es Connector Object using the search body you created. 

> *###SearchTerm### is what we are searching in query and the same text is copied in Search Term Field.*

<img src="https://github.com/elastic/xavier/blob/master/src/images/SingleSearchSFDCEsConnectorRecord.png" alt="Kibana Query" />

<strong>Sample Usage</strong>
```
// This is your text to search may be an inputText on Visualforce
public String searchStr {get; set;}   
 
public String getSearchItemsSingleSearch (){
  String responseStr;
  // Unique Record Name field Value On ES Connector 
  String unique_record_name = 'my_demo'; 
  HttpRequest req = Sf_Es_Connector.buildGetRequest(unique_record_name, searchStr);
  if (req != null) {
    responseStr =   Sf_Es_Connector.getResponseString(req);
  }
  return response;
}
```

### 3.2 Search Multiple Search Terms

Write a Elasticsearch query to search your desired index/types/etc. 
```
GET my_demo_index/_search
{
  "size": 10,
  "query" : {
    "bool": {
      "should": [
        {
          "match_phrase": {
            "field1": {
              "query": "###Search1###"
            }
          }
        },
        {
          "match_phrase": {
            "field1": {
              "query": "###Search2###"
            }
          }
        }      
      ]
    }
  }
}
```

As in 3.1, copy the query and create a record in Es Connector Object.

> *###Search1### and  ###Search2### are dynamic strings used  in query and are " |" separated in Search Term Field.*

<img src="https://github.com/elastic/xavier/blob/master/src/images/MultipleSearchSfConnector.png" alt="Kibana Query" />

<strong>Sample Usage</strong>
```
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
```

### 3.4 Parsing Elasticsearch Response

The framework does not cover parsing the response as every use case will return a different
set of fields but it is fairly easy to do. The below code gives you an idea of the wrappers
needed to parse the entire object returned.

**Important:** *APEX does not support **_source** naming convention of one of the key 
fields in Elasticsearch so we have already replaced **"_source"** with **"source_x"***

```
  /**
   * @description Entire Response Object of es response. It is a an outer hit which has list of
   *              Inner Hits and every inner hit has a source
   */
  public class EntireObj {
    public outerHit hits;
  }
  
  /**
   * @description Outer hit of es response.It is a List of Inner Hits  
   */
  public class outerHit {
    public List <individualHit> hits;
  }
  
  /**
   * @description Inner hit of es response
   */
   public class individualHit {
     public individualSource source_x;
   }  
  
  /**
   * @description  Source Class to parse the ES Response inner hit source
   *                which has fields body of record
   */
  public class individualSource {
    public String id;
    public String field1;
    public String field2;
  }
```
