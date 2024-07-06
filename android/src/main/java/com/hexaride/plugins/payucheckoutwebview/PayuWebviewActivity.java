package com.hexaride.plugins.payucheckoutwebview;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;

public class PayuWebviewActivity extends Activity {
    private WebView webView;
    private ProgressBar progressBar;
    private final String TAG = "PayuWebViewPlugin";
    private String callbackUrl;


    @Override
    public void onBackPressed() {
        Log.d(TAG, "Back pressed inside plugin");
        if (webView != null) {
            webView.evaluateJavascript(
                    """
                            (function (){
                                    const back = document.querySelector('#merchant-logo-row > i');
                                if (back){
                                    back.click()
                                    return true;
                                }
                                else return false;
                            })()""", value -> {
                        Log.d(TAG, "callback value: " + value);
                        if (value.equals("false")) {
                            if (webView.canGoBack()) {
                                webView.goBack();
                            } else {
//                                         Show a confirmation dialog
                                new AlertDialog.Builder(this)
                                        .setTitle("Confirm Exit")
                                        .setMessage("Are you sure you want to exit?")
                                        .setPositiveButton(android.R.string.yes, (dialog, which) -> {
                                            // Close the WebView and set it to null
                                            finish();
                                        })
                                        .setNegativeButton(android.R.string.no, null)
                                        .setIcon(android.R.drawable.ic_dialog_alert)
                                        .show();
                            }
                        }
                    });
        }

    }

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.payu_layout_main);

        webView = findViewById(R.id.PayuWebview);
        progressBar = findViewById(R.id.PayuProgressBar);

        // Enable JavaScript
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.getSettings().setLoadWithOverviewMode(true);
        webView.setVerticalScrollBarEnabled(true);

        webView.getSettings().setMixedContentMode(0);
        webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        // Handle page loading events
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                Log.d(TAG, "onPageStarted: " + url);

                if (callbackUrl != null && url.startsWith(callbackUrl)) {
                    Log.d(TAG, "success: " + url);
                    finish();
                }
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                progressBar.setVisibility(View.GONE);
            }
        });

        // Set a WebChromeClient to handle loading progress
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                progressBar.setProgress(newProgress);
            }
        });

        // Load the URL from the intent
        String url = getIntent().getStringExtra("url");
        String postData = getIntent().getStringExtra("postData");
        callbackUrl = getIntent().getStringExtra("callbackUrl");
        if (url != null) {
            assert postData != null;
            webView.postUrl(url, postData.getBytes());
        }
    }
}

