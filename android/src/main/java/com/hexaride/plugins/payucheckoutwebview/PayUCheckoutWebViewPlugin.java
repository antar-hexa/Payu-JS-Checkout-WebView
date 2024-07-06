package com.hexaride.plugins.payucheckoutwebview;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.nfc.Tag;
import android.util.Log;
import android.view.View;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.ProgressBar;

import androidx.activity.OnBackPressedCallback;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "PayUCheckoutWebView")
public class PayUCheckoutWebViewPlugin extends Plugin {

    private WebView webView;
    private String callbackUrl;
    private static final String TAG = "CapacitorWebViewPlugin";
    private OnBackPressedCallback onBackPressedCallback;
    private ProgressBar progressBar;

    private void initializeBackListener() {
        onBackPressedCallback = new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                Log.d(TAG, "Back pressed inside plugin");

                if (webView != null) {
                    webView.evaluateJavascript(
                            "(function (){\n" +
                                    "        const back = document.querySelector('#merchant-logo-row > i');\n" +
                                    "    if (back){\n" +
                                    "        back.click()\n" +
                                    "        return true;    \n" +
                                    "    }  \n" +
                                    "    else return false;\n" +
                                    "})()", value -> {
                                Log.d(TAG, "callback value: " + value + " true");
                                if (value.equals("true")) {
                                    //do dothing
                                } else {
                                    if (webView.canGoBack()) {
                                        webView.goBack();
                                    } else {
//                                         Show a confirmation dialog
                                        new AlertDialog.Builder(getActivity())
                                                .setTitle("Confirm Exit")
                                                .setMessage("Are you sure you want to exit?")
                                                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                                    public void onClick(DialogInterface dialog, int which) {
                                                        // Close the WebView and set it to null
                                                        closeWebView();
                                                    }
                                                })
                                                .setNegativeButton(android.R.string.no, null)
                                                .setIcon(android.R.drawable.ic_dialog_alert)
                                                .show();
                                    }
                                }
                            });
                }

            }
        };

        getActivity().getOnBackPressedDispatcher().addCallback(getActivity(), onBackPressedCallback);
    }

    private void removeBackListener() {
        if (onBackPressedCallback != null) {
            onBackPressedCallback.setEnabled(false);
            onBackPressedCallback.remove();
        }
    }

    public void closeWebView() {
        getActivity().runOnUiThread(() -> {
            if (webView != null) {
                ((FrameLayout) webView.getParent()).removeView(webView);
                webView = null;
                removeBackListener();
            }
        });
    }

    public void showProgressBar() {
        if (progressBar != null) {
            progressBar.setVisibility(View.VISIBLE);
        }
    }

    public void hideProgressBar() {
        if (progressBar != null) {
            progressBar.setVisibility(View.GONE);
        }
    }
    @PluginMethod
    public void openWebView(PluginCall call) {

        String url = call.getString("url");
        String postData = call.getString("postData");
        callbackUrl = call.getString("callbackUrl");


        if (url == null) {
            call.reject("URL is required");
            return;
        }

        getActivity().runOnUiThread(() -> {
            initializeBackListener();
            if (webView != null) {
                closeWebView(null);
            }

             webView = new WebView(getContext());
//            webView = findViewById(R.id.PayuWebview);
//            progressBar = webView.findViewById(R.id.PayuProgressBar);
            showProgressBar();
            webView.setWebViewClient(new MyWebViewClient());

            webView.getSettings().setJavaScriptEnabled(true);
            webView.getSettings().setDomStorageEnabled(true);
            webView.getSettings().setLoadWithOverviewMode(true);
            webView.setVerticalScrollBarEnabled(true);

            webView.postUrl(url, postData.getBytes());
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
            );
            getActivity().addContentView(webView, params);

            call.resolve();
        });
    }

    @PluginMethod
    public void closeWebView(PluginCall call) {
        getActivity().runOnUiThread(() -> {
            if (webView != null) {
                ((FrameLayout) webView.getParent()).removeView(webView);
                webView = null;

            }
            if (call != null) {
                call.resolve();
            }
        });
    }

    private class MyWebViewClient extends WebViewClient {

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            String url = request.getUrl().toString();
            if (url.contains("upi://pay")) {
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.setData(Uri.parse(url));
                    getContext().startActivity(intent);
                } catch (Exception e) {
                    view.loadUrl(url);
                }
            } else {
                view.loadUrl(url);
            }
            return true;
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            Log.d(TAG, "onPageFinished: " + url);
            hideProgressBar();
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            super.onPageStarted(view, url, favicon);
            Log.d(TAG, "onPageStarted: " + url);
            Log.d(TAG, "onPageStarted: " + view.getUrl());

            if (callbackUrl != null && url.startsWith(callbackUrl)) {
                Log.d(TAG, "success: " + url.toString());
                closeWebView();
            }
        }

        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            super.onReceivedError(view, request, error);
            Log.d(TAG, "onPageFinished: " + error.toString());
        }
    }
}
