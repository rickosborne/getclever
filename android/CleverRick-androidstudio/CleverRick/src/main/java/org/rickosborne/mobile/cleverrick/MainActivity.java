package org.rickosborne.mobile.cleverrick;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.content.Context;
import android.util.Base64;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

public class MainActivity extends Activity {

    private EditText txtApiKey;
    private TextView txtSectionCount, txtStudentCount, txtStuPerSec, txtLog;
    private Button btnFetch;
    private ProgressBar spinFetch;
    private URI apiUrl;
    private String unknown, sectionCount, studentCount, stuPerSec;

    private void ld(String msg) {
        Log.d(getClass().getName(), msg);
        txtLog.setText(msg + "\n" + txtLog.getText());
    }
    private URI makeUri(String uri) { try { return new URI(uri); } catch (URISyntaxException ex) { ld("Bad URI:" + uri); } return null; }

    private String apiKey() {
        String key = txtApiKey.getText().toString();
        if (key.length() > 0) { return key; }
        return getString(R.string.apiKeyDefault);
    }

    public class AsyncGetData extends AsyncTask<Void, String, Void> {

        private void ld(final String msg) {
            Log.d(getClass().getName(), msg);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    txtLog.setText(msg + "\n" + txtLog.getText());
                }
            });
        }

        protected void onPreExecute() {
            ld("AsyncGetData:onPreExecute");
            sectionCount = unknown;
            studentCount = unknown;
            stuPerSec = unknown;
            btnFetch.setEnabled(false);
            btnFetch.setVisibility(View.INVISIBLE);
            spinFetch.setVisibility(View.VISIBLE);
            txtApiKey.setEnabled(false);
        }

        @Override
        protected Void doInBackground(Void... params) {
            ld("AsyncGetData:doInBackground");
            ld("api endpoint:" + apiUrl.toString());
            try {
                DefaultHttpClient client = new DefaultHttpClient();
                client.getCredentialsProvider().setCredentials(new AuthScope(AuthScope.ANY_HOST, AuthScope.ANY_PORT), new UsernamePasswordCredentials(apiKey(), ""));
                HttpGet request = new HttpGet(apiUrl);
                // this works around an obscure bug for "empty challenge"
                request.addHeader("Authorization", "Basic "+Base64.encodeToString((apiKey() + ":").getBytes(),Base64.NO_WRAP));
                try {
                    HttpResponse response = client.execute(request);
                    ld("status:" + response.getStatusLine());
                    if (response.getStatusLine().getStatusCode() != 200) {
                        throw new Exception("The service API returned a bad status: " + response.getStatusLine());
                    }
                    HttpEntity entity = response.getEntity();
                    String contentType = entity.getContentType().getValue();
                    ld("Content-Type: " + contentType);
                    if (!contentType.contains("json")) {
                        throw new Exception("The service API returned data that's freaking me out, man: " + contentType);
                    }
                    BufferedReader in = new BufferedReader(new InputStreamReader(entity.getContent()));
                    String line;
                    while ((line = in.readLine()) != null) {
                        ld(line.substring(0, 10) + "..." + line.substring(line.length() - 10));
                        if (line.length() < 2) {
                            ld("heartbeat");
                        }
                        else if ((line.charAt(0) == '{') && (line.charAt(line.length() - 1) == '}')) {
                            try {
                                JSONObject json = new JSONObject(line);
                                if (json.has("data")) {
                                    JSONArray sections = json.getJSONArray("data");
                                    if (sections != null) {
                                        int secCount = sections.length();
                                        int stuCount = 0;
                                        for (int i = 0; i < secCount; i++) {
                                            JSONObject section = sections.getJSONObject(i);
                                            if (section.has("data")) {
                                                JSONObject sectionData = section.getJSONObject("data");
                                                if (sectionData.has("students")) {
                                                    JSONArray students = sectionData.getJSONArray("students");
                                                    stuCount += students.length();
                                                }
                                            }
                                        }
                                        sectionCount = String.valueOf(secCount);
                                        studentCount = String.valueOf(stuCount);
                                        stuPerSec = String.format("%.2f", (float) stuCount / (float) secCount);
                                    }
                                }
                            } catch (JSONException e) {
                                ld("Bad JSON:" + line + "\n" + e.toString());
                                // e.printStackTrace();
                            }
                        }
                    }
                } catch (IOException e) {
                    ld(e.toString());
                    e.printStackTrace();
                }
            } catch (Exception e) {
                ld(e.toString());
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onProgressUpdate(String... values) {
            super.onProgressUpdate(values);
            for (int i = 0; i < values.length; i++) {
                ld(values[i]);
            }
        }

        protected void onPostExecute(Void v) {
            ld("AsyncFetch:onPostExecute");
            txtSectionCount.setText(sectionCount);
            txtStudentCount.setText(studentCount);
            txtStuPerSec.setText(stuPerSec);
            txtApiKey.setEnabled(true);
            spinFetch.setVisibility(View.INVISIBLE);
            btnFetch.setVisibility(View.VISIBLE);
            btnFetch.setEnabled(true);
        }
    }

    public void fetchData (View senderButton) {
        ld("fetchData");
        new AsyncGetData().execute((Void)null);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        txtApiKey = (EditText) findViewById(R.id.txtApiKey);
        txtSectionCount = (TextView) findViewById(R.id.txtSectionCount);
        txtStudentCount = (TextView) findViewById(R.id.txtStudentCount);
        txtStuPerSec = (TextView) findViewById(R.id.txtStuPerSec);
        btnFetch = (Button) findViewById(R.id.btnFetch);
        spinFetch = (ProgressBar) findViewById(R.id.spinFetch);
        txtLog = (TextView) findViewById(R.id.txtLog);
        apiUrl = makeUri(getString(R.string.apiSections));
        unknown = getString(R.string.unknown);
        sectionCount = unknown;
        studentCount = unknown;
        stuPerSec = unknown;
        txtApiKey.setOnEditorActionListener(new OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEND) {
                    InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
                    fetchData(null);
                }
                return true;
            }
        });
    }

}
