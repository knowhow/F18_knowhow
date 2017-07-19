import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
 
import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.layout.VBox;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;
 

import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.CookieStore;
import java.net.HttpCookie;
import java.net.URI;
import java.util.Arrays;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Iterator;
import java.io.IOException;
import java.util.*;

public class HelloFXBrowser extends Application {
 
    @Override
    public void start(final Stage stage) {
 
       if ("Windows XP".equals(System.getProperty("os.name"))){ 
          System.load("c:\\jfxwebkit_xp.dll");
        }



        Button buttonURL = new Button("Load Page https://eclipse.org");
        Button buttonHtmlString = new Button("Load HML String");
        Button buttonHtmlFile = new Button("terminal 188");
 
        final WebView browser = new WebView();
        final WebEngine webEngine = browser.getEngine();
 
        buttonURL.setOnAction(new EventHandler<ActionEvent>() {
 
            @Override
            public void handle(ActionEvent event) {
                String url = "https://google.ba";



            webEngine.locationProperty().addListener((observable, oldValue, newValue) -> {
                 String location = (String)newValue;
                 int index = location.indexOf("code=");
                 if (index >= 0) {
                     String code = location.substring(index + 5);
                     System.out.println( "code=" + code );
                 } else {
                     System.out.println( "x=" + location );
                 }
            });

                // Load a page from remote url.
                webEngine.load(url);

            }
        });
 



        buttonHtmlString.setOnAction(new EventHandler<ActionEvent>() {
 
            @Override
            public void handle(ActionEvent event) {
                String html = "<html><h1>Hello</h1><h2>Hello</h2></html>";
                // Load HTML String
                webEngine.loadContent(html);
            }
        });
        buttonHtmlFile.setOnAction(new EventHandler<ActionEvent>() {
 
            @Override
            public void handle(ActionEvent event) {


                String url = "http://localhost.com:8080";
                webEngine.load(url);
 
            }
        });
 
        VBox root = new VBox();
        root.setPadding(new Insets(5));
        root.setSpacing(5);
        root.getChildren().addAll(buttonURL, buttonHtmlString, buttonHtmlFile, browser);
 
        Scene scene = new Scene(root);
 
        stage.setTitle("JavaFX ");
        stage.setScene(scene);
        stage.setWidth(450);
        stage.setHeight(500);
 
        stage.show();
    }
 
    public static void main(String[] args) {

        //com.sun.webkit.network.CookieManager manager = new com.sun.webkit.network.CookieManager();


        java.net.CookieHandler.setDefault(new com.sun.webkit.network.CookieManager());
        launch(args);

        //java.net.CookieHandler.setDefault( manager ) ;
        
         //manager.getCookieStore().removeAll();

        //CookieStore cookieStore = java.net.CookieHandler.getDefault().getCookieStore();

        //abstract Map<String,List<String>>	get(URI uri, Map<String,List<String>> requestHeaders)

        Map<String, List<String>> headers = new LinkedHashMap<String, List<String>>();
        URI uri = URI.create("https://www.google.ba");
        headers.put("Set-Cookie", Arrays.asList("COOKI=01"));
try {
        java.net.CookieHandler.getDefault().put(uri, headers);
} catch (IOException e)  {
System.out.println("Completed!");

};

        //get(URI uri, Map<String,List<String>> requestHeaders)

        Map<String, List<String>> headers2 = new LinkedHashMap<String, List<String>>();


try {
        headers2 = java.net.CookieHandler.getDefault().get(uri, headers2);
         System.out.println("3333333!");
} catch (IOException e)  {
         System.out.println("GCompleted!");

};


        Set set = headers2.entrySet();
      
        // Get an iterator
        Iterator i = set.iterator();
      
        // Display elements
        while(i.hasNext()) {
          Map.Entry me = (Map.Entry)i.next();
          System.out.print(me.getKey() + ": ");
          System.out.println(me.getValue());
       }

/*
        // Collection Iterator
        Iterator<Entry<String, List<String>>> iterator = headers2.iterator();
 
        while(iterator.hasNext()) {
 
            Entry<String, List<String>> entry = headers2.next();
 
            System.out.println("\nkey : "  + entry.getKey() 
                    + "\nvalue " + entry.getValue() + ":");
 
        }

*/


        //List<HttpCookie> cookies = cookieStore.getCookies();
        //for (HttpCookie cookie : cookies) {
        //   System.out.println(cookie);
        //}

    }

 
}
