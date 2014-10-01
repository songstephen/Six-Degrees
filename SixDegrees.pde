// Project 3: Data Portrait
// "6 Degrees of Association" by Stephen Song (ssong73)
// LMC 2700 Fall 2014

// inspiration
// http://www.chrisharrison.net/index.php/Visualizations/Welcome

// METAPHORS
// 1) Six degrees of separation
// 2) After six degrees away, a search term could be so different
// 3) Each word only appears once; if it's been in the search already, it will
// not appear in future searches
// 4) If you want to travel down a word, pick wisely
// 5) Choosing a word and having its related results out will remove a lot of
// the possible search queries related to that original word later on

import java.util.Comparator;
import java.util.HashSet;
import java.util.TreeMap;
import java.util.Map.Entry;

// text entries/filters
HashMap<String, Integer> map = new HashMap();
HashSet<String> seenWords = new HashSet();
HashSet<String> stopWords = new HashSet();

// text items
ArrayList<String>[] cols;
int[] selected = new int[6];
int degree = 1;
int TEXT_SIZE = 10;
int PADDING = 10;

// text processing
String currentQuery = "";
String typing = "";
boolean started = false;

// colors
color bg = #0b0c0c;
color panel = #181a1a;
color light = #cecece;
color muted = #464949;
color[] rainbow = {#f05f73, #f66c3d, #f6d746, #96ca4d, #2ca7c1, #913dcb};

// sets up program
void setup() {
    size(900, 600);
    setupWordFilters();
    initalize();
}

// starts the application in a clean slate
void initalize() {
    cols = new ArrayList[6];
    for (int i = 0; i < 6; i++) {
        cols[i] = new ArrayList();
        selected[i] = -1;
    }
}

// draw loop
void draw() {
    background(bg);
    fill(panel);
    rect(0, 520, width, 80);
    textSize(20);
    fill(light);
    text(typing, 10, 540);

    // draw the text items
    textSize(TEXT_SIZE);
    for (int i = 0; i < cols.length; i++) {
        for (int j = 0; cols[i] != null && j < cols[i].size(); j++) {
            if (j == selected[i]) {
                fill(rainbow[i]);
            } else if (degree == i) {
                fill(light);
            } else {
                fill(muted);
            }
            text(cols[i].get(j), PADDING + 150 * i,
                PADDING + TEXT_SIZE + j * TEXT_SIZE);
        }
    }
}

// manage clicked items
void mouseClicked() {
    if (mouseX > 150 + PADDING * degree && mouseX < 150 * (degree + 1) + PADDING
        && degree < 6 && mouseY < PADDING + cols[degree].size() * TEXT_SIZE
        && mouseY > PADDING) {
            selected[degree] = (mouseY - PADDING) / TEXT_SIZE;
            currentQuery = cols[degree].get((mouseY - PADDING) / TEXT_SIZE);
            degree++;
            if (degree < 6) {
                loadData(currentQuery);
            }
    }
}

// keyboard input to enter the initial search and to control the program
void keyPressed() {
    // implement resetting
    // implement help menus
    if (!started) {
        if (key == '\n') {
            // START THE PROGRAM YOOOOO
            started = true;
            cols[0].add(typing);
            selected[0] = 0;
            loadData(typing);
        } else if((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) {
            typing = typing + key; 
        } else if (key == BACKSPACE && typing.length() > 0) {
            typing = typing.substring(0, typing.length() - 1);
        }
    }
}

// accesses, filters, sorts, and displays the data
void loadData(String query) {
    // loads the data
    SearchQuery mySearch = new SearchQuery(query, 200);
    println("Starting search...");
    JSONArray JSONresults = mySearch.search();
    println("Calculating word counts...");

    if (JSONresults.size() == 0) { // no results
        println("No results found.");
    } else { // results found
        for (int i = 0; i < JSONresults.size (); i++) {
            // obtain word counts
            JSONObject rec = JSONresults.getJSONObject(i);
            try {
                JSONObject src = rec.getJSONObject("sourceResource");
                JSONArray descriptions = src.getJSONArray("description");
                String[] arr = descriptions.getString(0)
                    .split("[\\p{Punct}\\s\\d]+");
                for (String s: arr) {
                    if (!s.equalsIgnoreCase(query)) {
                        Integer count = map.get(s.toLowerCase());
                        if (!s.toLowerCase().equals(query) && count == null) {
                            map.put(s.toLowerCase(), 1);
                        }
                        else {
                            map.put(s.toLowerCase(), count + 1);
                        }
                    }
                }
            } catch (Exception e) {
            }
        } // end for

        // anonymous inner comparator for sorting TreeMap entries
        TreeMap<String,Integer> sortedMap = new TreeMap<String,Integer>
            (new Comparator<String>(){
                public int compare(String o1, String o2) {
                    if (map.get(o1) <= map.get(o2)) {
                        return -1;
                    } else {
                        return 1;
                    }
                }
            });

        // filter stop words and exceptionally short entries
        println("Ranking word counts...");
        for (Entry<String, Integer> e: map.entrySet()) {
            if (!stopWords.contains(e.getKey().toLowerCase())
                    && !seenWords.contains(e.getKey().toLowerCase())
                    && e.getKey().length() > 2) {
                sortedMap.put(e.getKey(), e.getValue());
            }
        }

        // selects the most frequent words
        println("Selecting highest frequency words...");
        for (int i = 0; i < 50 && !sortedMap.isEmpty(); i++) {
            Entry<String, Integer> entry = sortedMap.pollLastEntry();
            seenWords.add(entry.getKey());
            cols[degree].add(entry.getKey());
        }
    }
}

// Populates the stop words filter to help remove common language words
// Default English Stopwords List from http://www.ranks.nl/stopwords/
void setupWordFilters() {
    String stopWordsString = "a,able,about,across,after,all,almost,also,am,"
    + "among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,"
    + "did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,"
    + "hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,"
    + "likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,"
    + "only,or,other,our,own,rather,said,say,says,she,should,since,so,some,"
    + "than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,"
    + "wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,"
    + "would,yet,you,your";
    for (String s: stopWordsString.split("\\,")) {
        stopWords.add(s);
    }
}