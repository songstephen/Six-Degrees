// Project 3: Data Portrait
// "6 Degrees of Association" by Stephen Song (ssong73)
// LMC 2700 Fall 2014

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
int[] selected;
int degree;
int TEXT_SIZE = 10;
int PADDING = 10;

// fonts
PFont DroidSans;

// text processing and control
boolean runable = false;
boolean started = false;
String currentQuery = "";
String status = "please type a word - press enter to proceed";
String title = "six degrees of association by stephen song";
String typing = "";

// colors
color bg = #0b0c0c;
color panel = #181a1a;
color light = #cecece;
color muted = #464949;
color[] rainbow = {#f05f73, #f66c3d, #f6d746, #96ca4d, #2ca7c1, #913dcb};

// sets up program
void setup() {
    size(900, 600);
    DroidSans = loadFont("DroidSans-10.vlw");
    setupWordFilters();
    initalize();
}

// starts the application in a clean slate
void initalize() {
    cols = new ArrayList[6];
    selected = new int[6];
    status = "please type a word - press enter to proceed";
    map = new HashMap();
    seenWords = new HashSet();
    degree = 0;
    currentQuery = "";
    typing = "";
    for (int i = 0; i < 6; i++) {
        cols[i] = new ArrayList();
        selected[i] = -1;
    }
    cols[0].add("type a word to search");
}

// draw loop
void draw() {
    background(bg);
    fill(panel);
    noStroke();
    rect(0, 580, width, 20);
    textFont(DroidSans, TEXT_SIZE);
    fill(light);
    textAlign(LEFT);
    text(title, 7, 593);
    textAlign(RIGHT);
    text(status, width - 7, 593);
    textAlign(LEFT);

    // hover colors
    if (mouseX > 150 + PADDING * degree && mouseX < 150 * (degree + 1) + PADDING
        && degree < 6 && mouseY < PADDING + cols[degree].size() * TEXT_SIZE
        && mouseY > PADDING && runable && degree != 0) {
        selected[degree] = (mouseY - PADDING) / TEXT_SIZE;
    } else if (degree < 6) {
        selected[degree] = -1;
    }

    // draw the text items
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
        && mouseY > PADDING && runable) {
            selected[degree] = (mouseY - PADDING) / TEXT_SIZE;
            currentQuery = cols[degree].get((mouseY - PADDING) / TEXT_SIZE);
            degree++;
            if (degree < 6) {
                runable = false;
                runable = loadData(currentQuery);
            } else {
                status = "word association done - press backspace to restart";
                runable = false;
            }
    }
}

// keyboard input to enter the initial search and to control the program
void keyPressed() {
    if (!started) {
        if (key == '\n' && runable) { // start the program
            degree++;
            started = true;
            selected[0] = 0;
            redraw();
            loadData(typing);
        } else if((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) {
            typing = typing + key;
            runable = true;
            cols[0].remove(0);
            cols[0].add(typing);
        } else if (key == BACKSPACE && typing.length() > 0) {
            typing = typing.substring(0, typing.length() - 1);
            cols[0].remove(0);
            if (typing.length() > 0) {
                cols[0].add(typing);
            } else {
                cols[0].add("Type a word to search");
                runable = false;
            }
        }
    }
    if (started && key == BACKSPACE) { // reset the program
        initalize();
        started = false;
    }
}

// accesses, filters, sorts, and displays the data
boolean loadData(String query) {
    
    // loads the data
    SearchQuery mySearch = new SearchQuery(query, 200);
    JSONArray JSONresults = mySearch.search();

    // process each entry
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
    for (Entry<String, Integer> e: map.entrySet()) {
        if (!stopWords.contains(e.getKey().toLowerCase())
                && !seenWords.contains(e.getKey().toLowerCase())
                && e.getKey().length() > 2) {
            sortedMap.put(e.getKey(), e.getValue());
        }
    }

    // no entries case
    if (sortedMap.isEmpty()) {
        cols[degree].add("no results found");
        status = "word association done - press backspace to restart";
        runable = false;
        return false;
    }

    // selects the most frequent words
    for (int i = 0; i < 56 && !sortedMap.isEmpty(); i++) {
        Entry<String, Integer> entry = sortedMap.pollLastEntry();
        seenWords.add(entry.getKey());
        cols[degree].add(entry.getKey());
    }
    status = "click on the next word you want - backspace to restart";
    return true;
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