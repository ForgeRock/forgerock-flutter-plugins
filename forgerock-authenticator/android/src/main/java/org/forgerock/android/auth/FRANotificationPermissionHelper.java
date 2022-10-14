package org.forgerock.android.auth;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;

public class FRANotificationPermissionHelper extends Fragment {

    static final String TAG = FRANotificationPermissionHelper.class.getName();

    private static final int REQUEST_NOTIFICATION_PERMISSION = 101;

    private FragmentActivity activity;

    private FRANotificationPermissionHelper() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        activity = null;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_NOTIFICATION_PERMISSION) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Logger.debug(TAG, "Notification permission granted.");
            } else {
                Logger.debug(TAG, "Notification permission denied.");
            }
        }
    }

    /**
     * Request the new notification permission to the app
     */
    @RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
    public void requestNotificationPermission() {
        if(ActivityCompat.shouldShowRequestPermissionRationale(this.activity, Manifest.permission.POST_NOTIFICATIONS)) {
//            final FragmentActivity _activity = this.activity;
//            new AlertDialog.Builder(this.activity)
//                    .setTitle("Notification Permission required")
//                    .setMessage("Notification Permission is needed in order to receive Push Authentication requests on your device. " +
//                            "If you deny, you will be unable to use Push accounts. Do you want to enable Notifications?")
//                    .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
//                        @Override
//                        public void onClick(DialogInterface dialog, int which) {
//                            ActivityCompat.requestPermissions(
//                                    _activity,
//                                    new String[]{Manifest.permission.POST_NOTIFICATIONS},
//                                    REQUEST_NOTIFICATION_PERMISSION);
//                        }
//                    })
//                    .setNegativeButton("No", new DialogInterface.OnClickListener() {
//                        @Override
//                        public void onClick(DialogInterface dialog, int which) {
//                            dialog.dismiss();
//                        }
//                    }).create().show();
        } else {
            ActivityCompat.requestPermissions(
                    this.activity,
                    new String[]{Manifest.permission.POST_NOTIFICATIONS},
                    REQUEST_NOTIFICATION_PERMISSION);
        }
    }

    /**
     * Initialize a fragment to handle Notification permission request.
     * @param activity the activity that will host the new Fragment
     * @return the Fragment
     */
   public static FRANotificationPermissionHelper init(FragmentActivity activity) {
        FragmentManager fragmentManager = activity.getSupportFragmentManager();
        FRANotificationPermissionHelper existing = (FRANotificationPermissionHelper) fragmentManager.findFragmentByTag(TAG);
        if (existing != null) {
            existing.activity = null;
            fragmentManager.beginTransaction().remove(existing).commitNow();
        }

        FRANotificationPermissionHelper fragment = new FRANotificationPermissionHelper();
        fragment.activity = activity;
        fragmentManager.beginTransaction().add(fragment, FRANotificationPermissionHelper.TAG).commit();

        return fragment;
    }

}
