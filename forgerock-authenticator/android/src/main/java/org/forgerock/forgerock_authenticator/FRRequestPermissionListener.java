/*
 * Copyright (c) 2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.forgerock_authenticator;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.FragmentActivity;

import org.forgerock.android.auth.FRANotificationPermissionHelper;

import io.flutter.plugin.common.PluginRegistry;

@RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
public class FRRequestPermissionListener implements PluginRegistry.RequestPermissionsResultListener {

    static final String TAG = FRRequestPermissionListener.class.getName();

    private static final int REQUEST_PERMISSION = 101;

    private final String[] permission = {
            Manifest.permission.POST_NOTIFICATIONS,
    };

    interface PermissionManager {
        boolean isPermissionGranted();

        void askForPermission();
    }

    public interface RequestPermission {

        void onRequestPermissionSuccess();

        void onRequestPermissionFailure();
    }

    private RequestPermission mRequestPermission;

    private final PermissionManager permissionManager;

    FRRequestPermissionListener(final FragmentActivity activity) {
        permissionManager = new PermissionManager() {
            @Override
            public boolean isPermissionGranted() {
                for (String s : permission) {
                    if (ActivityCompat.checkSelfPermission(activity, s) != PackageManager.PERMISSION_GRANTED) {
                        return false;
                    }
                }
                return true;
            }

            @Override
            public void askForPermission() {
                ActivityCompat.requestPermissions(activity, permission, REQUEST_PERMISSION);
            }
        };
    }

    public void requestPermissions(@NonNull RequestPermission mRequestPermission) {
        this.mRequestPermission = mRequestPermission;
        if (!permissionManager.isPermissionGranted()) {
            permissionManager.askForPermission();
        } else {
            mRequestPermission.onRequestPermissionSuccess();
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] strings, @NonNull int[] ints) {
        if (requestCode == REQUEST_PERMISSION) {
            boolean permissionGranted = true;
            for (int i : ints) {
                if (i != PackageManager.PERMISSION_GRANTED) {
                    permissionGranted = false;
                    break;
                }
            }
            if (permissionGranted) {
                mRequestPermission.onRequestPermissionSuccess();
            } else {
                mRequestPermission.onRequestPermissionFailure();
            }
            return true;
        } else {
            return false;
        }
    }
}
