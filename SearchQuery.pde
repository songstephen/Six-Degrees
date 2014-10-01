// Search wrapper provided from the LMC 2700 assignment
public class SearchQuery {
  private String apikey = "59fd11cdc4f6368286cec6cd480d4480";
  private String searchQuery;
  private String searchFilter;
  private int numPages;

  // Constructor
  public SearchQuery(String qu, int n) {
    searchQuery = qu;
    numPages = n;
    //Use this filter to narrow your search.
    searchFilter = "sourceResource.description=";
  }

  // Search function
  public JSONArray search() {
    String queryURL = "";
    //Modify search query here. You will need to string query parameters
    //together to get the JSON file you want.
    queryURL = "http://api.dp.la/v2/items?" + searchFilter + searchQuery
      + "&api_key=" + apikey + "&page_size=" + numPages;
    println("Search: " + queryURL);
    JSONObject dplaData = loadJSONObject(queryURL);
    JSONArray results = dplaData.getJSONArray("docs");  
    return results;
  }
}

