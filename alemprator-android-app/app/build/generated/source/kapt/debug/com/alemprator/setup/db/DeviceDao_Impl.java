package com.alemprator.setup.db;

import android.database.Cursor;
import android.os.CancellationSignal;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import java.lang.Class;
import java.lang.Exception;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class DeviceDao_Impl implements DeviceDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<Device> __insertionAdapterOfDevice;

  private final EntityInsertionAdapter<SubnetPool> __insertionAdapterOfSubnetPool;

  private final EntityDeletionOrUpdateAdapter<Device> __deletionAdapterOfDevice;

  public DeviceDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfDevice = new EntityInsertionAdapter<Device>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `devices` (`id`,`macAddress`,`deviceName`,`deviceType`,`lanIp`,`lanNetmask`,`wifiSsid`,`wifiKey`,`wifiChannel`,`wifi2gChannel`,`wifi2gMode`,`wifi2gWidth`,`wifi5gChannel`,`wifi5gMode`,`wifi5gWidth`,`wifi5gNameType`,`wifi5gCustomSsid`,`appendIpToSsid`,`otaWindowStart`,`otaWindowEnd`,`vlanEnabled`,`vlanId`,`appendIpToVlanSsid`,`disableResetButton`,`resetPressDuration`,`disableWpsButton`,`autoRebootEnabled`,`rootPassword`,`hotspotWanInterface`,`hotspotSubscriberInterface`,`hotspotPrimaryIp`,`hotspotPrimaryPoolStart`,`hotspotPrimaryPoolEnd`,`hotspotPrimaryPolicy`,`hotspotDnsName`,`hotspotDns1`,`hotspotDns2`,`hotspotBridgeAgeingTime`,`hotspotCardPage`,`hotspotRateLimit`,`hotspotMacCookie`,`hotspotAvailableSpeeds`,`hotspotSecondaryEnabled`,`hotspotSecondarySsid`,`hotspotSecondaryIp`,`hotspotTrialEnabled`,`hotspotTrialDuration`,`hotspotTrialUptimeLimit`,`radiusServer`,`radiusServerBackup`,`radiusSecret`,`radiusAuthPort`,`radiusAcctPort`,`radiusNasIp`,`radiusNasId`,`radiusInterimUpdate`,`radiusCoaEnabled`,`radiusCoaPort`,`restApiEnabled`,`restApiProto`,`restApiUsername`,`restApiPassword`,`portalSupportPhone`,`portalNotification`,`portalLiveEnabled`,`portalLiveUrl`,`portalBreakEnabled`,`portalBreakUrl`,`portalSpeedtestEnabled`,`maintenanceEnabled`,`maintenancePolicy`,`maintenanceStartTime`,`maintenanceEndTime`,`autoupdateStartTime`,`autoupdateEndTime`,`uplinkBand`,`uplinkSsid`,`uplinkKey`,`meshBand`,`meshId`,`meshKey`,`rebootHours`,`vlanSsid2g`,`vlanSsid5g`,`vlanSsidIpSuffix`,`hotspotSecondaryPoolStart`,`hotspotSecondaryPoolEnd`,`hotspotSecondaryPolicy`,`hotspotMacAuthEnabled`,`hotspotMacAuthSuffix`,`hotspotMacAuthPassword`,`hotspotWalledGarden`,`hotspotBrowserCookieEnabled`,`hotspotBrowserCookieDays`,`timestamp`,`isTemplate`) VALUES (nullif(?, 0),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final Device entity) {
        statement.bindLong(1, entity.getId());
        if (entity.getMacAddress() == null) {
          statement.bindNull(2);
        } else {
          statement.bindString(2, entity.getMacAddress());
        }
        if (entity.getDeviceName() == null) {
          statement.bindNull(3);
        } else {
          statement.bindString(3, entity.getDeviceName());
        }
        if (entity.getDeviceType() == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, entity.getDeviceType());
        }
        if (entity.getLanIp() == null) {
          statement.bindNull(5);
        } else {
          statement.bindString(5, entity.getLanIp());
        }
        if (entity.getLanNetmask() == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, entity.getLanNetmask());
        }
        if (entity.getWifiSsid() == null) {
          statement.bindNull(7);
        } else {
          statement.bindString(7, entity.getWifiSsid());
        }
        if (entity.getWifiKey() == null) {
          statement.bindNull(8);
        } else {
          statement.bindString(8, entity.getWifiKey());
        }
        if (entity.getWifiChannel() == null) {
          statement.bindNull(9);
        } else {
          statement.bindString(9, entity.getWifiChannel());
        }
        if (entity.getWifi2gChannel() == null) {
          statement.bindNull(10);
        } else {
          statement.bindString(10, entity.getWifi2gChannel());
        }
        if (entity.getWifi2gMode() == null) {
          statement.bindNull(11);
        } else {
          statement.bindString(11, entity.getWifi2gMode());
        }
        if (entity.getWifi2gWidth() == null) {
          statement.bindNull(12);
        } else {
          statement.bindString(12, entity.getWifi2gWidth());
        }
        if (entity.getWifi5gChannel() == null) {
          statement.bindNull(13);
        } else {
          statement.bindString(13, entity.getWifi5gChannel());
        }
        if (entity.getWifi5gMode() == null) {
          statement.bindNull(14);
        } else {
          statement.bindString(14, entity.getWifi5gMode());
        }
        if (entity.getWifi5gWidth() == null) {
          statement.bindNull(15);
        } else {
          statement.bindString(15, entity.getWifi5gWidth());
        }
        if (entity.getWifi5gNameType() == null) {
          statement.bindNull(16);
        } else {
          statement.bindString(16, entity.getWifi5gNameType());
        }
        if (entity.getWifi5gCustomSsid() == null) {
          statement.bindNull(17);
        } else {
          statement.bindString(17, entity.getWifi5gCustomSsid());
        }
        final int _tmp = entity.getAppendIpToSsid() ? 1 : 0;
        statement.bindLong(18, _tmp);
        if (entity.getOtaWindowStart() == null) {
          statement.bindNull(19);
        } else {
          statement.bindString(19, entity.getOtaWindowStart());
        }
        if (entity.getOtaWindowEnd() == null) {
          statement.bindNull(20);
        } else {
          statement.bindString(20, entity.getOtaWindowEnd());
        }
        final int _tmp_1 = entity.getVlanEnabled() ? 1 : 0;
        statement.bindLong(21, _tmp_1);
        if (entity.getVlanId() == null) {
          statement.bindNull(22);
        } else {
          statement.bindString(22, entity.getVlanId());
        }
        final int _tmp_2 = entity.getAppendIpToVlanSsid() ? 1 : 0;
        statement.bindLong(23, _tmp_2);
        final int _tmp_3 = entity.getDisableResetButton() ? 1 : 0;
        statement.bindLong(24, _tmp_3);
        if (entity.getResetPressDuration() == null) {
          statement.bindNull(25);
        } else {
          statement.bindString(25, entity.getResetPressDuration());
        }
        final int _tmp_4 = entity.getDisableWpsButton() ? 1 : 0;
        statement.bindLong(26, _tmp_4);
        final int _tmp_5 = entity.getAutoRebootEnabled() ? 1 : 0;
        statement.bindLong(27, _tmp_5);
        if (entity.getRootPassword() == null) {
          statement.bindNull(28);
        } else {
          statement.bindString(28, entity.getRootPassword());
        }
        if (entity.getHotspotWanInterface() == null) {
          statement.bindNull(29);
        } else {
          statement.bindString(29, entity.getHotspotWanInterface());
        }
        if (entity.getHotspotSubscriberInterface() == null) {
          statement.bindNull(30);
        } else {
          statement.bindString(30, entity.getHotspotSubscriberInterface());
        }
        if (entity.getHotspotPrimaryIp() == null) {
          statement.bindNull(31);
        } else {
          statement.bindString(31, entity.getHotspotPrimaryIp());
        }
        if (entity.getHotspotPrimaryPoolStart() == null) {
          statement.bindNull(32);
        } else {
          statement.bindString(32, entity.getHotspotPrimaryPoolStart());
        }
        if (entity.getHotspotPrimaryPoolEnd() == null) {
          statement.bindNull(33);
        } else {
          statement.bindString(33, entity.getHotspotPrimaryPoolEnd());
        }
        if (entity.getHotspotPrimaryPolicy() == null) {
          statement.bindNull(34);
        } else {
          statement.bindString(34, entity.getHotspotPrimaryPolicy());
        }
        if (entity.getHotspotDnsName() == null) {
          statement.bindNull(35);
        } else {
          statement.bindString(35, entity.getHotspotDnsName());
        }
        if (entity.getHotspotDns1() == null) {
          statement.bindNull(36);
        } else {
          statement.bindString(36, entity.getHotspotDns1());
        }
        if (entity.getHotspotDns2() == null) {
          statement.bindNull(37);
        } else {
          statement.bindString(37, entity.getHotspotDns2());
        }
        if (entity.getHotspotBridgeAgeingTime() == null) {
          statement.bindNull(38);
        } else {
          statement.bindString(38, entity.getHotspotBridgeAgeingTime());
        }
        if (entity.getHotspotCardPage() == null) {
          statement.bindNull(39);
        } else {
          statement.bindString(39, entity.getHotspotCardPage());
        }
        if (entity.getHotspotRateLimit() == null) {
          statement.bindNull(40);
        } else {
          statement.bindString(40, entity.getHotspotRateLimit());
        }
        final int _tmp_6 = entity.getHotspotMacCookie() ? 1 : 0;
        statement.bindLong(41, _tmp_6);
        if (entity.getHotspotAvailableSpeeds() == null) {
          statement.bindNull(42);
        } else {
          statement.bindString(42, entity.getHotspotAvailableSpeeds());
        }
        final int _tmp_7 = entity.getHotspotSecondaryEnabled() ? 1 : 0;
        statement.bindLong(43, _tmp_7);
        if (entity.getHotspotSecondarySsid() == null) {
          statement.bindNull(44);
        } else {
          statement.bindString(44, entity.getHotspotSecondarySsid());
        }
        if (entity.getHotspotSecondaryIp() == null) {
          statement.bindNull(45);
        } else {
          statement.bindString(45, entity.getHotspotSecondaryIp());
        }
        final int _tmp_8 = entity.getHotspotTrialEnabled() ? 1 : 0;
        statement.bindLong(46, _tmp_8);
        if (entity.getHotspotTrialDuration() == null) {
          statement.bindNull(47);
        } else {
          statement.bindString(47, entity.getHotspotTrialDuration());
        }
        if (entity.getHotspotTrialUptimeLimit() == null) {
          statement.bindNull(48);
        } else {
          statement.bindString(48, entity.getHotspotTrialUptimeLimit());
        }
        if (entity.getRadiusServer() == null) {
          statement.bindNull(49);
        } else {
          statement.bindString(49, entity.getRadiusServer());
        }
        if (entity.getRadiusServerBackup() == null) {
          statement.bindNull(50);
        } else {
          statement.bindString(50, entity.getRadiusServerBackup());
        }
        if (entity.getRadiusSecret() == null) {
          statement.bindNull(51);
        } else {
          statement.bindString(51, entity.getRadiusSecret());
        }
        if (entity.getRadiusAuthPort() == null) {
          statement.bindNull(52);
        } else {
          statement.bindString(52, entity.getRadiusAuthPort());
        }
        if (entity.getRadiusAcctPort() == null) {
          statement.bindNull(53);
        } else {
          statement.bindString(53, entity.getRadiusAcctPort());
        }
        if (entity.getRadiusNasIp() == null) {
          statement.bindNull(54);
        } else {
          statement.bindString(54, entity.getRadiusNasIp());
        }
        if (entity.getRadiusNasId() == null) {
          statement.bindNull(55);
        } else {
          statement.bindString(55, entity.getRadiusNasId());
        }
        if (entity.getRadiusInterimUpdate() == null) {
          statement.bindNull(56);
        } else {
          statement.bindString(56, entity.getRadiusInterimUpdate());
        }
        final int _tmp_9 = entity.getRadiusCoaEnabled() ? 1 : 0;
        statement.bindLong(57, _tmp_9);
        if (entity.getRadiusCoaPort() == null) {
          statement.bindNull(58);
        } else {
          statement.bindString(58, entity.getRadiusCoaPort());
        }
        final int _tmp_10 = entity.getRestApiEnabled() ? 1 : 0;
        statement.bindLong(59, _tmp_10);
        if (entity.getRestApiProto() == null) {
          statement.bindNull(60);
        } else {
          statement.bindString(60, entity.getRestApiProto());
        }
        if (entity.getRestApiUsername() == null) {
          statement.bindNull(61);
        } else {
          statement.bindString(61, entity.getRestApiUsername());
        }
        if (entity.getRestApiPassword() == null) {
          statement.bindNull(62);
        } else {
          statement.bindString(62, entity.getRestApiPassword());
        }
        if (entity.getPortalSupportPhone() == null) {
          statement.bindNull(63);
        } else {
          statement.bindString(63, entity.getPortalSupportPhone());
        }
        if (entity.getPortalNotification() == null) {
          statement.bindNull(64);
        } else {
          statement.bindString(64, entity.getPortalNotification());
        }
        final int _tmp_11 = entity.getPortalLiveEnabled() ? 1 : 0;
        statement.bindLong(65, _tmp_11);
        if (entity.getPortalLiveUrl() == null) {
          statement.bindNull(66);
        } else {
          statement.bindString(66, entity.getPortalLiveUrl());
        }
        final int _tmp_12 = entity.getPortalBreakEnabled() ? 1 : 0;
        statement.bindLong(67, _tmp_12);
        if (entity.getPortalBreakUrl() == null) {
          statement.bindNull(68);
        } else {
          statement.bindString(68, entity.getPortalBreakUrl());
        }
        final int _tmp_13 = entity.getPortalSpeedtestEnabled() ? 1 : 0;
        statement.bindLong(69, _tmp_13);
        final int _tmp_14 = entity.getMaintenanceEnabled() ? 1 : 0;
        statement.bindLong(70, _tmp_14);
        if (entity.getMaintenancePolicy() == null) {
          statement.bindNull(71);
        } else {
          statement.bindString(71, entity.getMaintenancePolicy());
        }
        if (entity.getMaintenanceStartTime() == null) {
          statement.bindNull(72);
        } else {
          statement.bindString(72, entity.getMaintenanceStartTime());
        }
        if (entity.getMaintenanceEndTime() == null) {
          statement.bindNull(73);
        } else {
          statement.bindString(73, entity.getMaintenanceEndTime());
        }
        if (entity.getAutoupdateStartTime() == null) {
          statement.bindNull(74);
        } else {
          statement.bindString(74, entity.getAutoupdateStartTime());
        }
        if (entity.getAutoupdateEndTime() == null) {
          statement.bindNull(75);
        } else {
          statement.bindString(75, entity.getAutoupdateEndTime());
        }
        if (entity.getUplinkBand() == null) {
          statement.bindNull(76);
        } else {
          statement.bindString(76, entity.getUplinkBand());
        }
        if (entity.getUplinkSsid() == null) {
          statement.bindNull(77);
        } else {
          statement.bindString(77, entity.getUplinkSsid());
        }
        if (entity.getUplinkKey() == null) {
          statement.bindNull(78);
        } else {
          statement.bindString(78, entity.getUplinkKey());
        }
        if (entity.getMeshBand() == null) {
          statement.bindNull(79);
        } else {
          statement.bindString(79, entity.getMeshBand());
        }
        if (entity.getMeshId() == null) {
          statement.bindNull(80);
        } else {
          statement.bindString(80, entity.getMeshId());
        }
        if (entity.getMeshKey() == null) {
          statement.bindNull(81);
        } else {
          statement.bindString(81, entity.getMeshKey());
        }
        if (entity.getRebootHours() == null) {
          statement.bindNull(82);
        } else {
          statement.bindString(82, entity.getRebootHours());
        }
        if (entity.getVlanSsid2g() == null) {
          statement.bindNull(83);
        } else {
          statement.bindString(83, entity.getVlanSsid2g());
        }
        if (entity.getVlanSsid5g() == null) {
          statement.bindNull(84);
        } else {
          statement.bindString(84, entity.getVlanSsid5g());
        }
        final int _tmp_15 = entity.getVlanSsidIpSuffix() ? 1 : 0;
        statement.bindLong(85, _tmp_15);
        if (entity.getHotspotSecondaryPoolStart() == null) {
          statement.bindNull(86);
        } else {
          statement.bindString(86, entity.getHotspotSecondaryPoolStart());
        }
        if (entity.getHotspotSecondaryPoolEnd() == null) {
          statement.bindNull(87);
        } else {
          statement.bindString(87, entity.getHotspotSecondaryPoolEnd());
        }
        if (entity.getHotspotSecondaryPolicy() == null) {
          statement.bindNull(88);
        } else {
          statement.bindString(88, entity.getHotspotSecondaryPolicy());
        }
        final int _tmp_16 = entity.getHotspotMacAuthEnabled() ? 1 : 0;
        statement.bindLong(89, _tmp_16);
        if (entity.getHotspotMacAuthSuffix() == null) {
          statement.bindNull(90);
        } else {
          statement.bindString(90, entity.getHotspotMacAuthSuffix());
        }
        if (entity.getHotspotMacAuthPassword() == null) {
          statement.bindNull(91);
        } else {
          statement.bindString(91, entity.getHotspotMacAuthPassword());
        }
        if (entity.getHotspotWalledGarden() == null) {
          statement.bindNull(92);
        } else {
          statement.bindString(92, entity.getHotspotWalledGarden());
        }
        final int _tmp_17 = entity.getHotspotBrowserCookieEnabled() ? 1 : 0;
        statement.bindLong(93, _tmp_17);
        if (entity.getHotspotBrowserCookieDays() == null) {
          statement.bindNull(94);
        } else {
          statement.bindString(94, entity.getHotspotBrowserCookieDays());
        }
        statement.bindLong(95, entity.getTimestamp());
        final int _tmp_18 = entity.isTemplate() ? 1 : 0;
        statement.bindLong(96, _tmp_18);
      }
    };
    this.__insertionAdapterOfSubnetPool = new EntityInsertionAdapter<SubnetPool>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `subnet_pools` (`id`,`deviceMac`,`poolNetwork`,`poolStart`,`poolEnd`,`timestamp`) VALUES (nullif(?, 0),?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final SubnetPool entity) {
        statement.bindLong(1, entity.getId());
        if (entity.getDeviceMac() == null) {
          statement.bindNull(2);
        } else {
          statement.bindString(2, entity.getDeviceMac());
        }
        if (entity.getPoolNetwork() == null) {
          statement.bindNull(3);
        } else {
          statement.bindString(3, entity.getPoolNetwork());
        }
        if (entity.getPoolStart() == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, entity.getPoolStart());
        }
        if (entity.getPoolEnd() == null) {
          statement.bindNull(5);
        } else {
          statement.bindString(5, entity.getPoolEnd());
        }
        statement.bindLong(6, entity.getTimestamp());
      }
    };
    this.__deletionAdapterOfDevice = new EntityDeletionOrUpdateAdapter<Device>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `devices` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final Device entity) {
        statement.bindLong(1, entity.getId());
      }
    };
  }

  @Override
  public Object insertDevice(final Device device, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfDevice.insert(device);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object insertSubnetPool(final SubnetPool pool,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfSubnetPool.insert(pool);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object deleteDevice(final Device device, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfDevice.handle(device);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object getAllDevices(final Continuation<? super List<Device>> $completion) {
    final String _sql = "SELECT * FROM devices ORDER BY timestamp DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<Device>>() {
      @Override
      @NonNull
      public List<Device> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfMacAddress = CursorUtil.getColumnIndexOrThrow(_cursor, "macAddress");
          final int _cursorIndexOfDeviceName = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceName");
          final int _cursorIndexOfDeviceType = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceType");
          final int _cursorIndexOfLanIp = CursorUtil.getColumnIndexOrThrow(_cursor, "lanIp");
          final int _cursorIndexOfLanNetmask = CursorUtil.getColumnIndexOrThrow(_cursor, "lanNetmask");
          final int _cursorIndexOfWifiSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiSsid");
          final int _cursorIndexOfWifiKey = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiKey");
          final int _cursorIndexOfWifiChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiChannel");
          final int _cursorIndexOfWifi2gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gChannel");
          final int _cursorIndexOfWifi2gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gMode");
          final int _cursorIndexOfWifi2gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gWidth");
          final int _cursorIndexOfWifi5gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gChannel");
          final int _cursorIndexOfWifi5gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gMode");
          final int _cursorIndexOfWifi5gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gWidth");
          final int _cursorIndexOfWifi5gNameType = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gNameType");
          final int _cursorIndexOfWifi5gCustomSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gCustomSsid");
          final int _cursorIndexOfAppendIpToSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToSsid");
          final int _cursorIndexOfOtaWindowStart = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowStart");
          final int _cursorIndexOfOtaWindowEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowEnd");
          final int _cursorIndexOfVlanEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanEnabled");
          final int _cursorIndexOfVlanId = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanId");
          final int _cursorIndexOfAppendIpToVlanSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToVlanSsid");
          final int _cursorIndexOfDisableResetButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableResetButton");
          final int _cursorIndexOfResetPressDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "resetPressDuration");
          final int _cursorIndexOfDisableWpsButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableWpsButton");
          final int _cursorIndexOfAutoRebootEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "autoRebootEnabled");
          final int _cursorIndexOfRootPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "rootPassword");
          final int _cursorIndexOfHotspotWanInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWanInterface");
          final int _cursorIndexOfHotspotSubscriberInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSubscriberInterface");
          final int _cursorIndexOfHotspotPrimaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryIp");
          final int _cursorIndexOfHotspotPrimaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolStart");
          final int _cursorIndexOfHotspotPrimaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolEnd");
          final int _cursorIndexOfHotspotPrimaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPolicy");
          final int _cursorIndexOfHotspotDnsName = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDnsName");
          final int _cursorIndexOfHotspotDns1 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns1");
          final int _cursorIndexOfHotspotDns2 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns2");
          final int _cursorIndexOfHotspotBridgeAgeingTime = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBridgeAgeingTime");
          final int _cursorIndexOfHotspotCardPage = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotCardPage");
          final int _cursorIndexOfHotspotRateLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotRateLimit");
          final int _cursorIndexOfHotspotMacCookie = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacCookie");
          final int _cursorIndexOfHotspotAvailableSpeeds = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotAvailableSpeeds");
          final int _cursorIndexOfHotspotSecondaryEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryEnabled");
          final int _cursorIndexOfHotspotSecondarySsid = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondarySsid");
          final int _cursorIndexOfHotspotSecondaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryIp");
          final int _cursorIndexOfHotspotTrialEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialEnabled");
          final int _cursorIndexOfHotspotTrialDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialDuration");
          final int _cursorIndexOfHotspotTrialUptimeLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialUptimeLimit");
          final int _cursorIndexOfRadiusServer = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServer");
          final int _cursorIndexOfRadiusServerBackup = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServerBackup");
          final int _cursorIndexOfRadiusSecret = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusSecret");
          final int _cursorIndexOfRadiusAuthPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAuthPort");
          final int _cursorIndexOfRadiusAcctPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAcctPort");
          final int _cursorIndexOfRadiusNasIp = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasIp");
          final int _cursorIndexOfRadiusNasId = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasId");
          final int _cursorIndexOfRadiusInterimUpdate = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusInterimUpdate");
          final int _cursorIndexOfRadiusCoaEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaEnabled");
          final int _cursorIndexOfRadiusCoaPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaPort");
          final int _cursorIndexOfRestApiEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiEnabled");
          final int _cursorIndexOfRestApiProto = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiProto");
          final int _cursorIndexOfRestApiUsername = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiUsername");
          final int _cursorIndexOfRestApiPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiPassword");
          final int _cursorIndexOfPortalSupportPhone = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSupportPhone");
          final int _cursorIndexOfPortalNotification = CursorUtil.getColumnIndexOrThrow(_cursor, "portalNotification");
          final int _cursorIndexOfPortalLiveEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveEnabled");
          final int _cursorIndexOfPortalLiveUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveUrl");
          final int _cursorIndexOfPortalBreakEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakEnabled");
          final int _cursorIndexOfPortalBreakUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakUrl");
          final int _cursorIndexOfPortalSpeedtestEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSpeedtestEnabled");
          final int _cursorIndexOfMaintenanceEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEnabled");
          final int _cursorIndexOfMaintenancePolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenancePolicy");
          final int _cursorIndexOfMaintenanceStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceStartTime");
          final int _cursorIndexOfMaintenanceEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEndTime");
          final int _cursorIndexOfAutoupdateStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateStartTime");
          final int _cursorIndexOfAutoupdateEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateEndTime");
          final int _cursorIndexOfUplinkBand = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkBand");
          final int _cursorIndexOfUplinkSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkSsid");
          final int _cursorIndexOfUplinkKey = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkKey");
          final int _cursorIndexOfMeshBand = CursorUtil.getColumnIndexOrThrow(_cursor, "meshBand");
          final int _cursorIndexOfMeshId = CursorUtil.getColumnIndexOrThrow(_cursor, "meshId");
          final int _cursorIndexOfMeshKey = CursorUtil.getColumnIndexOrThrow(_cursor, "meshKey");
          final int _cursorIndexOfRebootHours = CursorUtil.getColumnIndexOrThrow(_cursor, "rebootHours");
          final int _cursorIndexOfVlanSsid2g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid2g");
          final int _cursorIndexOfVlanSsid5g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid5g");
          final int _cursorIndexOfVlanSsidIpSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsidIpSuffix");
          final int _cursorIndexOfHotspotSecondaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolStart");
          final int _cursorIndexOfHotspotSecondaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolEnd");
          final int _cursorIndexOfHotspotSecondaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPolicy");
          final int _cursorIndexOfHotspotMacAuthEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthEnabled");
          final int _cursorIndexOfHotspotMacAuthSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthSuffix");
          final int _cursorIndexOfHotspotMacAuthPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthPassword");
          final int _cursorIndexOfHotspotWalledGarden = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWalledGarden");
          final int _cursorIndexOfHotspotBrowserCookieEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieEnabled");
          final int _cursorIndexOfHotspotBrowserCookieDays = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieDays");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfIsTemplate = CursorUtil.getColumnIndexOrThrow(_cursor, "isTemplate");
          final List<Device> _result = new ArrayList<Device>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final Device _item;
            final int _tmpId;
            _tmpId = _cursor.getInt(_cursorIndexOfId);
            final String _tmpMacAddress;
            if (_cursor.isNull(_cursorIndexOfMacAddress)) {
              _tmpMacAddress = null;
            } else {
              _tmpMacAddress = _cursor.getString(_cursorIndexOfMacAddress);
            }
            final String _tmpDeviceName;
            if (_cursor.isNull(_cursorIndexOfDeviceName)) {
              _tmpDeviceName = null;
            } else {
              _tmpDeviceName = _cursor.getString(_cursorIndexOfDeviceName);
            }
            final String _tmpDeviceType;
            if (_cursor.isNull(_cursorIndexOfDeviceType)) {
              _tmpDeviceType = null;
            } else {
              _tmpDeviceType = _cursor.getString(_cursorIndexOfDeviceType);
            }
            final String _tmpLanIp;
            if (_cursor.isNull(_cursorIndexOfLanIp)) {
              _tmpLanIp = null;
            } else {
              _tmpLanIp = _cursor.getString(_cursorIndexOfLanIp);
            }
            final String _tmpLanNetmask;
            if (_cursor.isNull(_cursorIndexOfLanNetmask)) {
              _tmpLanNetmask = null;
            } else {
              _tmpLanNetmask = _cursor.getString(_cursorIndexOfLanNetmask);
            }
            final String _tmpWifiSsid;
            if (_cursor.isNull(_cursorIndexOfWifiSsid)) {
              _tmpWifiSsid = null;
            } else {
              _tmpWifiSsid = _cursor.getString(_cursorIndexOfWifiSsid);
            }
            final String _tmpWifiKey;
            if (_cursor.isNull(_cursorIndexOfWifiKey)) {
              _tmpWifiKey = null;
            } else {
              _tmpWifiKey = _cursor.getString(_cursorIndexOfWifiKey);
            }
            final String _tmpWifiChannel;
            if (_cursor.isNull(_cursorIndexOfWifiChannel)) {
              _tmpWifiChannel = null;
            } else {
              _tmpWifiChannel = _cursor.getString(_cursorIndexOfWifiChannel);
            }
            final String _tmpWifi2gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi2gChannel)) {
              _tmpWifi2gChannel = null;
            } else {
              _tmpWifi2gChannel = _cursor.getString(_cursorIndexOfWifi2gChannel);
            }
            final String _tmpWifi2gMode;
            if (_cursor.isNull(_cursorIndexOfWifi2gMode)) {
              _tmpWifi2gMode = null;
            } else {
              _tmpWifi2gMode = _cursor.getString(_cursorIndexOfWifi2gMode);
            }
            final String _tmpWifi2gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi2gWidth)) {
              _tmpWifi2gWidth = null;
            } else {
              _tmpWifi2gWidth = _cursor.getString(_cursorIndexOfWifi2gWidth);
            }
            final String _tmpWifi5gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi5gChannel)) {
              _tmpWifi5gChannel = null;
            } else {
              _tmpWifi5gChannel = _cursor.getString(_cursorIndexOfWifi5gChannel);
            }
            final String _tmpWifi5gMode;
            if (_cursor.isNull(_cursorIndexOfWifi5gMode)) {
              _tmpWifi5gMode = null;
            } else {
              _tmpWifi5gMode = _cursor.getString(_cursorIndexOfWifi5gMode);
            }
            final String _tmpWifi5gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi5gWidth)) {
              _tmpWifi5gWidth = null;
            } else {
              _tmpWifi5gWidth = _cursor.getString(_cursorIndexOfWifi5gWidth);
            }
            final String _tmpWifi5gNameType;
            if (_cursor.isNull(_cursorIndexOfWifi5gNameType)) {
              _tmpWifi5gNameType = null;
            } else {
              _tmpWifi5gNameType = _cursor.getString(_cursorIndexOfWifi5gNameType);
            }
            final String _tmpWifi5gCustomSsid;
            if (_cursor.isNull(_cursorIndexOfWifi5gCustomSsid)) {
              _tmpWifi5gCustomSsid = null;
            } else {
              _tmpWifi5gCustomSsid = _cursor.getString(_cursorIndexOfWifi5gCustomSsid);
            }
            final boolean _tmpAppendIpToSsid;
            final int _tmp;
            _tmp = _cursor.getInt(_cursorIndexOfAppendIpToSsid);
            _tmpAppendIpToSsid = _tmp != 0;
            final String _tmpOtaWindowStart;
            if (_cursor.isNull(_cursorIndexOfOtaWindowStart)) {
              _tmpOtaWindowStart = null;
            } else {
              _tmpOtaWindowStart = _cursor.getString(_cursorIndexOfOtaWindowStart);
            }
            final String _tmpOtaWindowEnd;
            if (_cursor.isNull(_cursorIndexOfOtaWindowEnd)) {
              _tmpOtaWindowEnd = null;
            } else {
              _tmpOtaWindowEnd = _cursor.getString(_cursorIndexOfOtaWindowEnd);
            }
            final boolean _tmpVlanEnabled;
            final int _tmp_1;
            _tmp_1 = _cursor.getInt(_cursorIndexOfVlanEnabled);
            _tmpVlanEnabled = _tmp_1 != 0;
            final String _tmpVlanId;
            if (_cursor.isNull(_cursorIndexOfVlanId)) {
              _tmpVlanId = null;
            } else {
              _tmpVlanId = _cursor.getString(_cursorIndexOfVlanId);
            }
            final boolean _tmpAppendIpToVlanSsid;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfAppendIpToVlanSsid);
            _tmpAppendIpToVlanSsid = _tmp_2 != 0;
            final boolean _tmpDisableResetButton;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfDisableResetButton);
            _tmpDisableResetButton = _tmp_3 != 0;
            final String _tmpResetPressDuration;
            if (_cursor.isNull(_cursorIndexOfResetPressDuration)) {
              _tmpResetPressDuration = null;
            } else {
              _tmpResetPressDuration = _cursor.getString(_cursorIndexOfResetPressDuration);
            }
            final boolean _tmpDisableWpsButton;
            final int _tmp_4;
            _tmp_4 = _cursor.getInt(_cursorIndexOfDisableWpsButton);
            _tmpDisableWpsButton = _tmp_4 != 0;
            final boolean _tmpAutoRebootEnabled;
            final int _tmp_5;
            _tmp_5 = _cursor.getInt(_cursorIndexOfAutoRebootEnabled);
            _tmpAutoRebootEnabled = _tmp_5 != 0;
            final String _tmpRootPassword;
            if (_cursor.isNull(_cursorIndexOfRootPassword)) {
              _tmpRootPassword = null;
            } else {
              _tmpRootPassword = _cursor.getString(_cursorIndexOfRootPassword);
            }
            final String _tmpHotspotWanInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotWanInterface)) {
              _tmpHotspotWanInterface = null;
            } else {
              _tmpHotspotWanInterface = _cursor.getString(_cursorIndexOfHotspotWanInterface);
            }
            final String _tmpHotspotSubscriberInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotSubscriberInterface)) {
              _tmpHotspotSubscriberInterface = null;
            } else {
              _tmpHotspotSubscriberInterface = _cursor.getString(_cursorIndexOfHotspotSubscriberInterface);
            }
            final String _tmpHotspotPrimaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryIp)) {
              _tmpHotspotPrimaryIp = null;
            } else {
              _tmpHotspotPrimaryIp = _cursor.getString(_cursorIndexOfHotspotPrimaryIp);
            }
            final String _tmpHotspotPrimaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolStart)) {
              _tmpHotspotPrimaryPoolStart = null;
            } else {
              _tmpHotspotPrimaryPoolStart = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolStart);
            }
            final String _tmpHotspotPrimaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolEnd)) {
              _tmpHotspotPrimaryPoolEnd = null;
            } else {
              _tmpHotspotPrimaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolEnd);
            }
            final String _tmpHotspotPrimaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPolicy)) {
              _tmpHotspotPrimaryPolicy = null;
            } else {
              _tmpHotspotPrimaryPolicy = _cursor.getString(_cursorIndexOfHotspotPrimaryPolicy);
            }
            final String _tmpHotspotDnsName;
            if (_cursor.isNull(_cursorIndexOfHotspotDnsName)) {
              _tmpHotspotDnsName = null;
            } else {
              _tmpHotspotDnsName = _cursor.getString(_cursorIndexOfHotspotDnsName);
            }
            final String _tmpHotspotDns1;
            if (_cursor.isNull(_cursorIndexOfHotspotDns1)) {
              _tmpHotspotDns1 = null;
            } else {
              _tmpHotspotDns1 = _cursor.getString(_cursorIndexOfHotspotDns1);
            }
            final String _tmpHotspotDns2;
            if (_cursor.isNull(_cursorIndexOfHotspotDns2)) {
              _tmpHotspotDns2 = null;
            } else {
              _tmpHotspotDns2 = _cursor.getString(_cursorIndexOfHotspotDns2);
            }
            final String _tmpHotspotBridgeAgeingTime;
            if (_cursor.isNull(_cursorIndexOfHotspotBridgeAgeingTime)) {
              _tmpHotspotBridgeAgeingTime = null;
            } else {
              _tmpHotspotBridgeAgeingTime = _cursor.getString(_cursorIndexOfHotspotBridgeAgeingTime);
            }
            final String _tmpHotspotCardPage;
            if (_cursor.isNull(_cursorIndexOfHotspotCardPage)) {
              _tmpHotspotCardPage = null;
            } else {
              _tmpHotspotCardPage = _cursor.getString(_cursorIndexOfHotspotCardPage);
            }
            final String _tmpHotspotRateLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotRateLimit)) {
              _tmpHotspotRateLimit = null;
            } else {
              _tmpHotspotRateLimit = _cursor.getString(_cursorIndexOfHotspotRateLimit);
            }
            final boolean _tmpHotspotMacCookie;
            final int _tmp_6;
            _tmp_6 = _cursor.getInt(_cursorIndexOfHotspotMacCookie);
            _tmpHotspotMacCookie = _tmp_6 != 0;
            final String _tmpHotspotAvailableSpeeds;
            if (_cursor.isNull(_cursorIndexOfHotspotAvailableSpeeds)) {
              _tmpHotspotAvailableSpeeds = null;
            } else {
              _tmpHotspotAvailableSpeeds = _cursor.getString(_cursorIndexOfHotspotAvailableSpeeds);
            }
            final boolean _tmpHotspotSecondaryEnabled;
            final int _tmp_7;
            _tmp_7 = _cursor.getInt(_cursorIndexOfHotspotSecondaryEnabled);
            _tmpHotspotSecondaryEnabled = _tmp_7 != 0;
            final String _tmpHotspotSecondarySsid;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondarySsid)) {
              _tmpHotspotSecondarySsid = null;
            } else {
              _tmpHotspotSecondarySsid = _cursor.getString(_cursorIndexOfHotspotSecondarySsid);
            }
            final String _tmpHotspotSecondaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryIp)) {
              _tmpHotspotSecondaryIp = null;
            } else {
              _tmpHotspotSecondaryIp = _cursor.getString(_cursorIndexOfHotspotSecondaryIp);
            }
            final boolean _tmpHotspotTrialEnabled;
            final int _tmp_8;
            _tmp_8 = _cursor.getInt(_cursorIndexOfHotspotTrialEnabled);
            _tmpHotspotTrialEnabled = _tmp_8 != 0;
            final String _tmpHotspotTrialDuration;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialDuration)) {
              _tmpHotspotTrialDuration = null;
            } else {
              _tmpHotspotTrialDuration = _cursor.getString(_cursorIndexOfHotspotTrialDuration);
            }
            final String _tmpHotspotTrialUptimeLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialUptimeLimit)) {
              _tmpHotspotTrialUptimeLimit = null;
            } else {
              _tmpHotspotTrialUptimeLimit = _cursor.getString(_cursorIndexOfHotspotTrialUptimeLimit);
            }
            final String _tmpRadiusServer;
            if (_cursor.isNull(_cursorIndexOfRadiusServer)) {
              _tmpRadiusServer = null;
            } else {
              _tmpRadiusServer = _cursor.getString(_cursorIndexOfRadiusServer);
            }
            final String _tmpRadiusServerBackup;
            if (_cursor.isNull(_cursorIndexOfRadiusServerBackup)) {
              _tmpRadiusServerBackup = null;
            } else {
              _tmpRadiusServerBackup = _cursor.getString(_cursorIndexOfRadiusServerBackup);
            }
            final String _tmpRadiusSecret;
            if (_cursor.isNull(_cursorIndexOfRadiusSecret)) {
              _tmpRadiusSecret = null;
            } else {
              _tmpRadiusSecret = _cursor.getString(_cursorIndexOfRadiusSecret);
            }
            final String _tmpRadiusAuthPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAuthPort)) {
              _tmpRadiusAuthPort = null;
            } else {
              _tmpRadiusAuthPort = _cursor.getString(_cursorIndexOfRadiusAuthPort);
            }
            final String _tmpRadiusAcctPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAcctPort)) {
              _tmpRadiusAcctPort = null;
            } else {
              _tmpRadiusAcctPort = _cursor.getString(_cursorIndexOfRadiusAcctPort);
            }
            final String _tmpRadiusNasIp;
            if (_cursor.isNull(_cursorIndexOfRadiusNasIp)) {
              _tmpRadiusNasIp = null;
            } else {
              _tmpRadiusNasIp = _cursor.getString(_cursorIndexOfRadiusNasIp);
            }
            final String _tmpRadiusNasId;
            if (_cursor.isNull(_cursorIndexOfRadiusNasId)) {
              _tmpRadiusNasId = null;
            } else {
              _tmpRadiusNasId = _cursor.getString(_cursorIndexOfRadiusNasId);
            }
            final String _tmpRadiusInterimUpdate;
            if (_cursor.isNull(_cursorIndexOfRadiusInterimUpdate)) {
              _tmpRadiusInterimUpdate = null;
            } else {
              _tmpRadiusInterimUpdate = _cursor.getString(_cursorIndexOfRadiusInterimUpdate);
            }
            final boolean _tmpRadiusCoaEnabled;
            final int _tmp_9;
            _tmp_9 = _cursor.getInt(_cursorIndexOfRadiusCoaEnabled);
            _tmpRadiusCoaEnabled = _tmp_9 != 0;
            final String _tmpRadiusCoaPort;
            if (_cursor.isNull(_cursorIndexOfRadiusCoaPort)) {
              _tmpRadiusCoaPort = null;
            } else {
              _tmpRadiusCoaPort = _cursor.getString(_cursorIndexOfRadiusCoaPort);
            }
            final boolean _tmpRestApiEnabled;
            final int _tmp_10;
            _tmp_10 = _cursor.getInt(_cursorIndexOfRestApiEnabled);
            _tmpRestApiEnabled = _tmp_10 != 0;
            final String _tmpRestApiProto;
            if (_cursor.isNull(_cursorIndexOfRestApiProto)) {
              _tmpRestApiProto = null;
            } else {
              _tmpRestApiProto = _cursor.getString(_cursorIndexOfRestApiProto);
            }
            final String _tmpRestApiUsername;
            if (_cursor.isNull(_cursorIndexOfRestApiUsername)) {
              _tmpRestApiUsername = null;
            } else {
              _tmpRestApiUsername = _cursor.getString(_cursorIndexOfRestApiUsername);
            }
            final String _tmpRestApiPassword;
            if (_cursor.isNull(_cursorIndexOfRestApiPassword)) {
              _tmpRestApiPassword = null;
            } else {
              _tmpRestApiPassword = _cursor.getString(_cursorIndexOfRestApiPassword);
            }
            final String _tmpPortalSupportPhone;
            if (_cursor.isNull(_cursorIndexOfPortalSupportPhone)) {
              _tmpPortalSupportPhone = null;
            } else {
              _tmpPortalSupportPhone = _cursor.getString(_cursorIndexOfPortalSupportPhone);
            }
            final String _tmpPortalNotification;
            if (_cursor.isNull(_cursorIndexOfPortalNotification)) {
              _tmpPortalNotification = null;
            } else {
              _tmpPortalNotification = _cursor.getString(_cursorIndexOfPortalNotification);
            }
            final boolean _tmpPortalLiveEnabled;
            final int _tmp_11;
            _tmp_11 = _cursor.getInt(_cursorIndexOfPortalLiveEnabled);
            _tmpPortalLiveEnabled = _tmp_11 != 0;
            final String _tmpPortalLiveUrl;
            if (_cursor.isNull(_cursorIndexOfPortalLiveUrl)) {
              _tmpPortalLiveUrl = null;
            } else {
              _tmpPortalLiveUrl = _cursor.getString(_cursorIndexOfPortalLiveUrl);
            }
            final boolean _tmpPortalBreakEnabled;
            final int _tmp_12;
            _tmp_12 = _cursor.getInt(_cursorIndexOfPortalBreakEnabled);
            _tmpPortalBreakEnabled = _tmp_12 != 0;
            final String _tmpPortalBreakUrl;
            if (_cursor.isNull(_cursorIndexOfPortalBreakUrl)) {
              _tmpPortalBreakUrl = null;
            } else {
              _tmpPortalBreakUrl = _cursor.getString(_cursorIndexOfPortalBreakUrl);
            }
            final boolean _tmpPortalSpeedtestEnabled;
            final int _tmp_13;
            _tmp_13 = _cursor.getInt(_cursorIndexOfPortalSpeedtestEnabled);
            _tmpPortalSpeedtestEnabled = _tmp_13 != 0;
            final boolean _tmpMaintenanceEnabled;
            final int _tmp_14;
            _tmp_14 = _cursor.getInt(_cursorIndexOfMaintenanceEnabled);
            _tmpMaintenanceEnabled = _tmp_14 != 0;
            final String _tmpMaintenancePolicy;
            if (_cursor.isNull(_cursorIndexOfMaintenancePolicy)) {
              _tmpMaintenancePolicy = null;
            } else {
              _tmpMaintenancePolicy = _cursor.getString(_cursorIndexOfMaintenancePolicy);
            }
            final String _tmpMaintenanceStartTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceStartTime)) {
              _tmpMaintenanceStartTime = null;
            } else {
              _tmpMaintenanceStartTime = _cursor.getString(_cursorIndexOfMaintenanceStartTime);
            }
            final String _tmpMaintenanceEndTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceEndTime)) {
              _tmpMaintenanceEndTime = null;
            } else {
              _tmpMaintenanceEndTime = _cursor.getString(_cursorIndexOfMaintenanceEndTime);
            }
            final String _tmpAutoupdateStartTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateStartTime)) {
              _tmpAutoupdateStartTime = null;
            } else {
              _tmpAutoupdateStartTime = _cursor.getString(_cursorIndexOfAutoupdateStartTime);
            }
            final String _tmpAutoupdateEndTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateEndTime)) {
              _tmpAutoupdateEndTime = null;
            } else {
              _tmpAutoupdateEndTime = _cursor.getString(_cursorIndexOfAutoupdateEndTime);
            }
            final String _tmpUplinkBand;
            if (_cursor.isNull(_cursorIndexOfUplinkBand)) {
              _tmpUplinkBand = null;
            } else {
              _tmpUplinkBand = _cursor.getString(_cursorIndexOfUplinkBand);
            }
            final String _tmpUplinkSsid;
            if (_cursor.isNull(_cursorIndexOfUplinkSsid)) {
              _tmpUplinkSsid = null;
            } else {
              _tmpUplinkSsid = _cursor.getString(_cursorIndexOfUplinkSsid);
            }
            final String _tmpUplinkKey;
            if (_cursor.isNull(_cursorIndexOfUplinkKey)) {
              _tmpUplinkKey = null;
            } else {
              _tmpUplinkKey = _cursor.getString(_cursorIndexOfUplinkKey);
            }
            final String _tmpMeshBand;
            if (_cursor.isNull(_cursorIndexOfMeshBand)) {
              _tmpMeshBand = null;
            } else {
              _tmpMeshBand = _cursor.getString(_cursorIndexOfMeshBand);
            }
            final String _tmpMeshId;
            if (_cursor.isNull(_cursorIndexOfMeshId)) {
              _tmpMeshId = null;
            } else {
              _tmpMeshId = _cursor.getString(_cursorIndexOfMeshId);
            }
            final String _tmpMeshKey;
            if (_cursor.isNull(_cursorIndexOfMeshKey)) {
              _tmpMeshKey = null;
            } else {
              _tmpMeshKey = _cursor.getString(_cursorIndexOfMeshKey);
            }
            final String _tmpRebootHours;
            if (_cursor.isNull(_cursorIndexOfRebootHours)) {
              _tmpRebootHours = null;
            } else {
              _tmpRebootHours = _cursor.getString(_cursorIndexOfRebootHours);
            }
            final String _tmpVlanSsid2g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid2g)) {
              _tmpVlanSsid2g = null;
            } else {
              _tmpVlanSsid2g = _cursor.getString(_cursorIndexOfVlanSsid2g);
            }
            final String _tmpVlanSsid5g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid5g)) {
              _tmpVlanSsid5g = null;
            } else {
              _tmpVlanSsid5g = _cursor.getString(_cursorIndexOfVlanSsid5g);
            }
            final boolean _tmpVlanSsidIpSuffix;
            final int _tmp_15;
            _tmp_15 = _cursor.getInt(_cursorIndexOfVlanSsidIpSuffix);
            _tmpVlanSsidIpSuffix = _tmp_15 != 0;
            final String _tmpHotspotSecondaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolStart)) {
              _tmpHotspotSecondaryPoolStart = null;
            } else {
              _tmpHotspotSecondaryPoolStart = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolStart);
            }
            final String _tmpHotspotSecondaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolEnd)) {
              _tmpHotspotSecondaryPoolEnd = null;
            } else {
              _tmpHotspotSecondaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolEnd);
            }
            final String _tmpHotspotSecondaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPolicy)) {
              _tmpHotspotSecondaryPolicy = null;
            } else {
              _tmpHotspotSecondaryPolicy = _cursor.getString(_cursorIndexOfHotspotSecondaryPolicy);
            }
            final boolean _tmpHotspotMacAuthEnabled;
            final int _tmp_16;
            _tmp_16 = _cursor.getInt(_cursorIndexOfHotspotMacAuthEnabled);
            _tmpHotspotMacAuthEnabled = _tmp_16 != 0;
            final String _tmpHotspotMacAuthSuffix;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthSuffix)) {
              _tmpHotspotMacAuthSuffix = null;
            } else {
              _tmpHotspotMacAuthSuffix = _cursor.getString(_cursorIndexOfHotspotMacAuthSuffix);
            }
            final String _tmpHotspotMacAuthPassword;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthPassword)) {
              _tmpHotspotMacAuthPassword = null;
            } else {
              _tmpHotspotMacAuthPassword = _cursor.getString(_cursorIndexOfHotspotMacAuthPassword);
            }
            final String _tmpHotspotWalledGarden;
            if (_cursor.isNull(_cursorIndexOfHotspotWalledGarden)) {
              _tmpHotspotWalledGarden = null;
            } else {
              _tmpHotspotWalledGarden = _cursor.getString(_cursorIndexOfHotspotWalledGarden);
            }
            final boolean _tmpHotspotBrowserCookieEnabled;
            final int _tmp_17;
            _tmp_17 = _cursor.getInt(_cursorIndexOfHotspotBrowserCookieEnabled);
            _tmpHotspotBrowserCookieEnabled = _tmp_17 != 0;
            final String _tmpHotspotBrowserCookieDays;
            if (_cursor.isNull(_cursorIndexOfHotspotBrowserCookieDays)) {
              _tmpHotspotBrowserCookieDays = null;
            } else {
              _tmpHotspotBrowserCookieDays = _cursor.getString(_cursorIndexOfHotspotBrowserCookieDays);
            }
            final long _tmpTimestamp;
            _tmpTimestamp = _cursor.getLong(_cursorIndexOfTimestamp);
            final boolean _tmpIsTemplate;
            final int _tmp_18;
            _tmp_18 = _cursor.getInt(_cursorIndexOfIsTemplate);
            _tmpIsTemplate = _tmp_18 != 0;
            _item = new Device(_tmpId,_tmpMacAddress,_tmpDeviceName,_tmpDeviceType,_tmpLanIp,_tmpLanNetmask,_tmpWifiSsid,_tmpWifiKey,_tmpWifiChannel,_tmpWifi2gChannel,_tmpWifi2gMode,_tmpWifi2gWidth,_tmpWifi5gChannel,_tmpWifi5gMode,_tmpWifi5gWidth,_tmpWifi5gNameType,_tmpWifi5gCustomSsid,_tmpAppendIpToSsid,_tmpOtaWindowStart,_tmpOtaWindowEnd,_tmpVlanEnabled,_tmpVlanId,_tmpAppendIpToVlanSsid,_tmpDisableResetButton,_tmpResetPressDuration,_tmpDisableWpsButton,_tmpAutoRebootEnabled,_tmpRootPassword,_tmpHotspotWanInterface,_tmpHotspotSubscriberInterface,_tmpHotspotPrimaryIp,_tmpHotspotPrimaryPoolStart,_tmpHotspotPrimaryPoolEnd,_tmpHotspotPrimaryPolicy,_tmpHotspotDnsName,_tmpHotspotDns1,_tmpHotspotDns2,_tmpHotspotBridgeAgeingTime,_tmpHotspotCardPage,_tmpHotspotRateLimit,_tmpHotspotMacCookie,_tmpHotspotAvailableSpeeds,_tmpHotspotSecondaryEnabled,_tmpHotspotSecondarySsid,_tmpHotspotSecondaryIp,_tmpHotspotTrialEnabled,_tmpHotspotTrialDuration,_tmpHotspotTrialUptimeLimit,_tmpRadiusServer,_tmpRadiusServerBackup,_tmpRadiusSecret,_tmpRadiusAuthPort,_tmpRadiusAcctPort,_tmpRadiusNasIp,_tmpRadiusNasId,_tmpRadiusInterimUpdate,_tmpRadiusCoaEnabled,_tmpRadiusCoaPort,_tmpRestApiEnabled,_tmpRestApiProto,_tmpRestApiUsername,_tmpRestApiPassword,_tmpPortalSupportPhone,_tmpPortalNotification,_tmpPortalLiveEnabled,_tmpPortalLiveUrl,_tmpPortalBreakEnabled,_tmpPortalBreakUrl,_tmpPortalSpeedtestEnabled,_tmpMaintenanceEnabled,_tmpMaintenancePolicy,_tmpMaintenanceStartTime,_tmpMaintenanceEndTime,_tmpAutoupdateStartTime,_tmpAutoupdateEndTime,_tmpUplinkBand,_tmpUplinkSsid,_tmpUplinkKey,_tmpMeshBand,_tmpMeshId,_tmpMeshKey,_tmpRebootHours,_tmpVlanSsid2g,_tmpVlanSsid5g,_tmpVlanSsidIpSuffix,_tmpHotspotSecondaryPoolStart,_tmpHotspotSecondaryPoolEnd,_tmpHotspotSecondaryPolicy,_tmpHotspotMacAuthEnabled,_tmpHotspotMacAuthSuffix,_tmpHotspotMacAuthPassword,_tmpHotspotWalledGarden,_tmpHotspotBrowserCookieEnabled,_tmpHotspotBrowserCookieDays,_tmpTimestamp,_tmpIsTemplate);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object getDeviceByMac(final String mac, final Continuation<? super Device> $completion) {
    final String _sql = "SELECT * FROM devices WHERE macAddress = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    if (mac == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindString(_argIndex, mac);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Device>() {
      @Override
      @Nullable
      public Device call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfMacAddress = CursorUtil.getColumnIndexOrThrow(_cursor, "macAddress");
          final int _cursorIndexOfDeviceName = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceName");
          final int _cursorIndexOfDeviceType = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceType");
          final int _cursorIndexOfLanIp = CursorUtil.getColumnIndexOrThrow(_cursor, "lanIp");
          final int _cursorIndexOfLanNetmask = CursorUtil.getColumnIndexOrThrow(_cursor, "lanNetmask");
          final int _cursorIndexOfWifiSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiSsid");
          final int _cursorIndexOfWifiKey = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiKey");
          final int _cursorIndexOfWifiChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiChannel");
          final int _cursorIndexOfWifi2gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gChannel");
          final int _cursorIndexOfWifi2gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gMode");
          final int _cursorIndexOfWifi2gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gWidth");
          final int _cursorIndexOfWifi5gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gChannel");
          final int _cursorIndexOfWifi5gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gMode");
          final int _cursorIndexOfWifi5gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gWidth");
          final int _cursorIndexOfWifi5gNameType = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gNameType");
          final int _cursorIndexOfWifi5gCustomSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gCustomSsid");
          final int _cursorIndexOfAppendIpToSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToSsid");
          final int _cursorIndexOfOtaWindowStart = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowStart");
          final int _cursorIndexOfOtaWindowEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowEnd");
          final int _cursorIndexOfVlanEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanEnabled");
          final int _cursorIndexOfVlanId = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanId");
          final int _cursorIndexOfAppendIpToVlanSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToVlanSsid");
          final int _cursorIndexOfDisableResetButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableResetButton");
          final int _cursorIndexOfResetPressDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "resetPressDuration");
          final int _cursorIndexOfDisableWpsButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableWpsButton");
          final int _cursorIndexOfAutoRebootEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "autoRebootEnabled");
          final int _cursorIndexOfRootPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "rootPassword");
          final int _cursorIndexOfHotspotWanInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWanInterface");
          final int _cursorIndexOfHotspotSubscriberInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSubscriberInterface");
          final int _cursorIndexOfHotspotPrimaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryIp");
          final int _cursorIndexOfHotspotPrimaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolStart");
          final int _cursorIndexOfHotspotPrimaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolEnd");
          final int _cursorIndexOfHotspotPrimaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPolicy");
          final int _cursorIndexOfHotspotDnsName = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDnsName");
          final int _cursorIndexOfHotspotDns1 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns1");
          final int _cursorIndexOfHotspotDns2 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns2");
          final int _cursorIndexOfHotspotBridgeAgeingTime = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBridgeAgeingTime");
          final int _cursorIndexOfHotspotCardPage = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotCardPage");
          final int _cursorIndexOfHotspotRateLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotRateLimit");
          final int _cursorIndexOfHotspotMacCookie = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacCookie");
          final int _cursorIndexOfHotspotAvailableSpeeds = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotAvailableSpeeds");
          final int _cursorIndexOfHotspotSecondaryEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryEnabled");
          final int _cursorIndexOfHotspotSecondarySsid = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondarySsid");
          final int _cursorIndexOfHotspotSecondaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryIp");
          final int _cursorIndexOfHotspotTrialEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialEnabled");
          final int _cursorIndexOfHotspotTrialDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialDuration");
          final int _cursorIndexOfHotspotTrialUptimeLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialUptimeLimit");
          final int _cursorIndexOfRadiusServer = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServer");
          final int _cursorIndexOfRadiusServerBackup = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServerBackup");
          final int _cursorIndexOfRadiusSecret = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusSecret");
          final int _cursorIndexOfRadiusAuthPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAuthPort");
          final int _cursorIndexOfRadiusAcctPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAcctPort");
          final int _cursorIndexOfRadiusNasIp = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasIp");
          final int _cursorIndexOfRadiusNasId = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasId");
          final int _cursorIndexOfRadiusInterimUpdate = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusInterimUpdate");
          final int _cursorIndexOfRadiusCoaEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaEnabled");
          final int _cursorIndexOfRadiusCoaPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaPort");
          final int _cursorIndexOfRestApiEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiEnabled");
          final int _cursorIndexOfRestApiProto = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiProto");
          final int _cursorIndexOfRestApiUsername = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiUsername");
          final int _cursorIndexOfRestApiPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiPassword");
          final int _cursorIndexOfPortalSupportPhone = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSupportPhone");
          final int _cursorIndexOfPortalNotification = CursorUtil.getColumnIndexOrThrow(_cursor, "portalNotification");
          final int _cursorIndexOfPortalLiveEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveEnabled");
          final int _cursorIndexOfPortalLiveUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveUrl");
          final int _cursorIndexOfPortalBreakEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakEnabled");
          final int _cursorIndexOfPortalBreakUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakUrl");
          final int _cursorIndexOfPortalSpeedtestEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSpeedtestEnabled");
          final int _cursorIndexOfMaintenanceEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEnabled");
          final int _cursorIndexOfMaintenancePolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenancePolicy");
          final int _cursorIndexOfMaintenanceStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceStartTime");
          final int _cursorIndexOfMaintenanceEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEndTime");
          final int _cursorIndexOfAutoupdateStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateStartTime");
          final int _cursorIndexOfAutoupdateEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateEndTime");
          final int _cursorIndexOfUplinkBand = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkBand");
          final int _cursorIndexOfUplinkSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkSsid");
          final int _cursorIndexOfUplinkKey = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkKey");
          final int _cursorIndexOfMeshBand = CursorUtil.getColumnIndexOrThrow(_cursor, "meshBand");
          final int _cursorIndexOfMeshId = CursorUtil.getColumnIndexOrThrow(_cursor, "meshId");
          final int _cursorIndexOfMeshKey = CursorUtil.getColumnIndexOrThrow(_cursor, "meshKey");
          final int _cursorIndexOfRebootHours = CursorUtil.getColumnIndexOrThrow(_cursor, "rebootHours");
          final int _cursorIndexOfVlanSsid2g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid2g");
          final int _cursorIndexOfVlanSsid5g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid5g");
          final int _cursorIndexOfVlanSsidIpSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsidIpSuffix");
          final int _cursorIndexOfHotspotSecondaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolStart");
          final int _cursorIndexOfHotspotSecondaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolEnd");
          final int _cursorIndexOfHotspotSecondaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPolicy");
          final int _cursorIndexOfHotspotMacAuthEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthEnabled");
          final int _cursorIndexOfHotspotMacAuthSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthSuffix");
          final int _cursorIndexOfHotspotMacAuthPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthPassword");
          final int _cursorIndexOfHotspotWalledGarden = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWalledGarden");
          final int _cursorIndexOfHotspotBrowserCookieEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieEnabled");
          final int _cursorIndexOfHotspotBrowserCookieDays = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieDays");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfIsTemplate = CursorUtil.getColumnIndexOrThrow(_cursor, "isTemplate");
          final Device _result;
          if (_cursor.moveToFirst()) {
            final int _tmpId;
            _tmpId = _cursor.getInt(_cursorIndexOfId);
            final String _tmpMacAddress;
            if (_cursor.isNull(_cursorIndexOfMacAddress)) {
              _tmpMacAddress = null;
            } else {
              _tmpMacAddress = _cursor.getString(_cursorIndexOfMacAddress);
            }
            final String _tmpDeviceName;
            if (_cursor.isNull(_cursorIndexOfDeviceName)) {
              _tmpDeviceName = null;
            } else {
              _tmpDeviceName = _cursor.getString(_cursorIndexOfDeviceName);
            }
            final String _tmpDeviceType;
            if (_cursor.isNull(_cursorIndexOfDeviceType)) {
              _tmpDeviceType = null;
            } else {
              _tmpDeviceType = _cursor.getString(_cursorIndexOfDeviceType);
            }
            final String _tmpLanIp;
            if (_cursor.isNull(_cursorIndexOfLanIp)) {
              _tmpLanIp = null;
            } else {
              _tmpLanIp = _cursor.getString(_cursorIndexOfLanIp);
            }
            final String _tmpLanNetmask;
            if (_cursor.isNull(_cursorIndexOfLanNetmask)) {
              _tmpLanNetmask = null;
            } else {
              _tmpLanNetmask = _cursor.getString(_cursorIndexOfLanNetmask);
            }
            final String _tmpWifiSsid;
            if (_cursor.isNull(_cursorIndexOfWifiSsid)) {
              _tmpWifiSsid = null;
            } else {
              _tmpWifiSsid = _cursor.getString(_cursorIndexOfWifiSsid);
            }
            final String _tmpWifiKey;
            if (_cursor.isNull(_cursorIndexOfWifiKey)) {
              _tmpWifiKey = null;
            } else {
              _tmpWifiKey = _cursor.getString(_cursorIndexOfWifiKey);
            }
            final String _tmpWifiChannel;
            if (_cursor.isNull(_cursorIndexOfWifiChannel)) {
              _tmpWifiChannel = null;
            } else {
              _tmpWifiChannel = _cursor.getString(_cursorIndexOfWifiChannel);
            }
            final String _tmpWifi2gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi2gChannel)) {
              _tmpWifi2gChannel = null;
            } else {
              _tmpWifi2gChannel = _cursor.getString(_cursorIndexOfWifi2gChannel);
            }
            final String _tmpWifi2gMode;
            if (_cursor.isNull(_cursorIndexOfWifi2gMode)) {
              _tmpWifi2gMode = null;
            } else {
              _tmpWifi2gMode = _cursor.getString(_cursorIndexOfWifi2gMode);
            }
            final String _tmpWifi2gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi2gWidth)) {
              _tmpWifi2gWidth = null;
            } else {
              _tmpWifi2gWidth = _cursor.getString(_cursorIndexOfWifi2gWidth);
            }
            final String _tmpWifi5gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi5gChannel)) {
              _tmpWifi5gChannel = null;
            } else {
              _tmpWifi5gChannel = _cursor.getString(_cursorIndexOfWifi5gChannel);
            }
            final String _tmpWifi5gMode;
            if (_cursor.isNull(_cursorIndexOfWifi5gMode)) {
              _tmpWifi5gMode = null;
            } else {
              _tmpWifi5gMode = _cursor.getString(_cursorIndexOfWifi5gMode);
            }
            final String _tmpWifi5gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi5gWidth)) {
              _tmpWifi5gWidth = null;
            } else {
              _tmpWifi5gWidth = _cursor.getString(_cursorIndexOfWifi5gWidth);
            }
            final String _tmpWifi5gNameType;
            if (_cursor.isNull(_cursorIndexOfWifi5gNameType)) {
              _tmpWifi5gNameType = null;
            } else {
              _tmpWifi5gNameType = _cursor.getString(_cursorIndexOfWifi5gNameType);
            }
            final String _tmpWifi5gCustomSsid;
            if (_cursor.isNull(_cursorIndexOfWifi5gCustomSsid)) {
              _tmpWifi5gCustomSsid = null;
            } else {
              _tmpWifi5gCustomSsid = _cursor.getString(_cursorIndexOfWifi5gCustomSsid);
            }
            final boolean _tmpAppendIpToSsid;
            final int _tmp;
            _tmp = _cursor.getInt(_cursorIndexOfAppendIpToSsid);
            _tmpAppendIpToSsid = _tmp != 0;
            final String _tmpOtaWindowStart;
            if (_cursor.isNull(_cursorIndexOfOtaWindowStart)) {
              _tmpOtaWindowStart = null;
            } else {
              _tmpOtaWindowStart = _cursor.getString(_cursorIndexOfOtaWindowStart);
            }
            final String _tmpOtaWindowEnd;
            if (_cursor.isNull(_cursorIndexOfOtaWindowEnd)) {
              _tmpOtaWindowEnd = null;
            } else {
              _tmpOtaWindowEnd = _cursor.getString(_cursorIndexOfOtaWindowEnd);
            }
            final boolean _tmpVlanEnabled;
            final int _tmp_1;
            _tmp_1 = _cursor.getInt(_cursorIndexOfVlanEnabled);
            _tmpVlanEnabled = _tmp_1 != 0;
            final String _tmpVlanId;
            if (_cursor.isNull(_cursorIndexOfVlanId)) {
              _tmpVlanId = null;
            } else {
              _tmpVlanId = _cursor.getString(_cursorIndexOfVlanId);
            }
            final boolean _tmpAppendIpToVlanSsid;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfAppendIpToVlanSsid);
            _tmpAppendIpToVlanSsid = _tmp_2 != 0;
            final boolean _tmpDisableResetButton;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfDisableResetButton);
            _tmpDisableResetButton = _tmp_3 != 0;
            final String _tmpResetPressDuration;
            if (_cursor.isNull(_cursorIndexOfResetPressDuration)) {
              _tmpResetPressDuration = null;
            } else {
              _tmpResetPressDuration = _cursor.getString(_cursorIndexOfResetPressDuration);
            }
            final boolean _tmpDisableWpsButton;
            final int _tmp_4;
            _tmp_4 = _cursor.getInt(_cursorIndexOfDisableWpsButton);
            _tmpDisableWpsButton = _tmp_4 != 0;
            final boolean _tmpAutoRebootEnabled;
            final int _tmp_5;
            _tmp_5 = _cursor.getInt(_cursorIndexOfAutoRebootEnabled);
            _tmpAutoRebootEnabled = _tmp_5 != 0;
            final String _tmpRootPassword;
            if (_cursor.isNull(_cursorIndexOfRootPassword)) {
              _tmpRootPassword = null;
            } else {
              _tmpRootPassword = _cursor.getString(_cursorIndexOfRootPassword);
            }
            final String _tmpHotspotWanInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotWanInterface)) {
              _tmpHotspotWanInterface = null;
            } else {
              _tmpHotspotWanInterface = _cursor.getString(_cursorIndexOfHotspotWanInterface);
            }
            final String _tmpHotspotSubscriberInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotSubscriberInterface)) {
              _tmpHotspotSubscriberInterface = null;
            } else {
              _tmpHotspotSubscriberInterface = _cursor.getString(_cursorIndexOfHotspotSubscriberInterface);
            }
            final String _tmpHotspotPrimaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryIp)) {
              _tmpHotspotPrimaryIp = null;
            } else {
              _tmpHotspotPrimaryIp = _cursor.getString(_cursorIndexOfHotspotPrimaryIp);
            }
            final String _tmpHotspotPrimaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolStart)) {
              _tmpHotspotPrimaryPoolStart = null;
            } else {
              _tmpHotspotPrimaryPoolStart = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolStart);
            }
            final String _tmpHotspotPrimaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolEnd)) {
              _tmpHotspotPrimaryPoolEnd = null;
            } else {
              _tmpHotspotPrimaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolEnd);
            }
            final String _tmpHotspotPrimaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPolicy)) {
              _tmpHotspotPrimaryPolicy = null;
            } else {
              _tmpHotspotPrimaryPolicy = _cursor.getString(_cursorIndexOfHotspotPrimaryPolicy);
            }
            final String _tmpHotspotDnsName;
            if (_cursor.isNull(_cursorIndexOfHotspotDnsName)) {
              _tmpHotspotDnsName = null;
            } else {
              _tmpHotspotDnsName = _cursor.getString(_cursorIndexOfHotspotDnsName);
            }
            final String _tmpHotspotDns1;
            if (_cursor.isNull(_cursorIndexOfHotspotDns1)) {
              _tmpHotspotDns1 = null;
            } else {
              _tmpHotspotDns1 = _cursor.getString(_cursorIndexOfHotspotDns1);
            }
            final String _tmpHotspotDns2;
            if (_cursor.isNull(_cursorIndexOfHotspotDns2)) {
              _tmpHotspotDns2 = null;
            } else {
              _tmpHotspotDns2 = _cursor.getString(_cursorIndexOfHotspotDns2);
            }
            final String _tmpHotspotBridgeAgeingTime;
            if (_cursor.isNull(_cursorIndexOfHotspotBridgeAgeingTime)) {
              _tmpHotspotBridgeAgeingTime = null;
            } else {
              _tmpHotspotBridgeAgeingTime = _cursor.getString(_cursorIndexOfHotspotBridgeAgeingTime);
            }
            final String _tmpHotspotCardPage;
            if (_cursor.isNull(_cursorIndexOfHotspotCardPage)) {
              _tmpHotspotCardPage = null;
            } else {
              _tmpHotspotCardPage = _cursor.getString(_cursorIndexOfHotspotCardPage);
            }
            final String _tmpHotspotRateLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotRateLimit)) {
              _tmpHotspotRateLimit = null;
            } else {
              _tmpHotspotRateLimit = _cursor.getString(_cursorIndexOfHotspotRateLimit);
            }
            final boolean _tmpHotspotMacCookie;
            final int _tmp_6;
            _tmp_6 = _cursor.getInt(_cursorIndexOfHotspotMacCookie);
            _tmpHotspotMacCookie = _tmp_6 != 0;
            final String _tmpHotspotAvailableSpeeds;
            if (_cursor.isNull(_cursorIndexOfHotspotAvailableSpeeds)) {
              _tmpHotspotAvailableSpeeds = null;
            } else {
              _tmpHotspotAvailableSpeeds = _cursor.getString(_cursorIndexOfHotspotAvailableSpeeds);
            }
            final boolean _tmpHotspotSecondaryEnabled;
            final int _tmp_7;
            _tmp_7 = _cursor.getInt(_cursorIndexOfHotspotSecondaryEnabled);
            _tmpHotspotSecondaryEnabled = _tmp_7 != 0;
            final String _tmpHotspotSecondarySsid;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondarySsid)) {
              _tmpHotspotSecondarySsid = null;
            } else {
              _tmpHotspotSecondarySsid = _cursor.getString(_cursorIndexOfHotspotSecondarySsid);
            }
            final String _tmpHotspotSecondaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryIp)) {
              _tmpHotspotSecondaryIp = null;
            } else {
              _tmpHotspotSecondaryIp = _cursor.getString(_cursorIndexOfHotspotSecondaryIp);
            }
            final boolean _tmpHotspotTrialEnabled;
            final int _tmp_8;
            _tmp_8 = _cursor.getInt(_cursorIndexOfHotspotTrialEnabled);
            _tmpHotspotTrialEnabled = _tmp_8 != 0;
            final String _tmpHotspotTrialDuration;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialDuration)) {
              _tmpHotspotTrialDuration = null;
            } else {
              _tmpHotspotTrialDuration = _cursor.getString(_cursorIndexOfHotspotTrialDuration);
            }
            final String _tmpHotspotTrialUptimeLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialUptimeLimit)) {
              _tmpHotspotTrialUptimeLimit = null;
            } else {
              _tmpHotspotTrialUptimeLimit = _cursor.getString(_cursorIndexOfHotspotTrialUptimeLimit);
            }
            final String _tmpRadiusServer;
            if (_cursor.isNull(_cursorIndexOfRadiusServer)) {
              _tmpRadiusServer = null;
            } else {
              _tmpRadiusServer = _cursor.getString(_cursorIndexOfRadiusServer);
            }
            final String _tmpRadiusServerBackup;
            if (_cursor.isNull(_cursorIndexOfRadiusServerBackup)) {
              _tmpRadiusServerBackup = null;
            } else {
              _tmpRadiusServerBackup = _cursor.getString(_cursorIndexOfRadiusServerBackup);
            }
            final String _tmpRadiusSecret;
            if (_cursor.isNull(_cursorIndexOfRadiusSecret)) {
              _tmpRadiusSecret = null;
            } else {
              _tmpRadiusSecret = _cursor.getString(_cursorIndexOfRadiusSecret);
            }
            final String _tmpRadiusAuthPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAuthPort)) {
              _tmpRadiusAuthPort = null;
            } else {
              _tmpRadiusAuthPort = _cursor.getString(_cursorIndexOfRadiusAuthPort);
            }
            final String _tmpRadiusAcctPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAcctPort)) {
              _tmpRadiusAcctPort = null;
            } else {
              _tmpRadiusAcctPort = _cursor.getString(_cursorIndexOfRadiusAcctPort);
            }
            final String _tmpRadiusNasIp;
            if (_cursor.isNull(_cursorIndexOfRadiusNasIp)) {
              _tmpRadiusNasIp = null;
            } else {
              _tmpRadiusNasIp = _cursor.getString(_cursorIndexOfRadiusNasIp);
            }
            final String _tmpRadiusNasId;
            if (_cursor.isNull(_cursorIndexOfRadiusNasId)) {
              _tmpRadiusNasId = null;
            } else {
              _tmpRadiusNasId = _cursor.getString(_cursorIndexOfRadiusNasId);
            }
            final String _tmpRadiusInterimUpdate;
            if (_cursor.isNull(_cursorIndexOfRadiusInterimUpdate)) {
              _tmpRadiusInterimUpdate = null;
            } else {
              _tmpRadiusInterimUpdate = _cursor.getString(_cursorIndexOfRadiusInterimUpdate);
            }
            final boolean _tmpRadiusCoaEnabled;
            final int _tmp_9;
            _tmp_9 = _cursor.getInt(_cursorIndexOfRadiusCoaEnabled);
            _tmpRadiusCoaEnabled = _tmp_9 != 0;
            final String _tmpRadiusCoaPort;
            if (_cursor.isNull(_cursorIndexOfRadiusCoaPort)) {
              _tmpRadiusCoaPort = null;
            } else {
              _tmpRadiusCoaPort = _cursor.getString(_cursorIndexOfRadiusCoaPort);
            }
            final boolean _tmpRestApiEnabled;
            final int _tmp_10;
            _tmp_10 = _cursor.getInt(_cursorIndexOfRestApiEnabled);
            _tmpRestApiEnabled = _tmp_10 != 0;
            final String _tmpRestApiProto;
            if (_cursor.isNull(_cursorIndexOfRestApiProto)) {
              _tmpRestApiProto = null;
            } else {
              _tmpRestApiProto = _cursor.getString(_cursorIndexOfRestApiProto);
            }
            final String _tmpRestApiUsername;
            if (_cursor.isNull(_cursorIndexOfRestApiUsername)) {
              _tmpRestApiUsername = null;
            } else {
              _tmpRestApiUsername = _cursor.getString(_cursorIndexOfRestApiUsername);
            }
            final String _tmpRestApiPassword;
            if (_cursor.isNull(_cursorIndexOfRestApiPassword)) {
              _tmpRestApiPassword = null;
            } else {
              _tmpRestApiPassword = _cursor.getString(_cursorIndexOfRestApiPassword);
            }
            final String _tmpPortalSupportPhone;
            if (_cursor.isNull(_cursorIndexOfPortalSupportPhone)) {
              _tmpPortalSupportPhone = null;
            } else {
              _tmpPortalSupportPhone = _cursor.getString(_cursorIndexOfPortalSupportPhone);
            }
            final String _tmpPortalNotification;
            if (_cursor.isNull(_cursorIndexOfPortalNotification)) {
              _tmpPortalNotification = null;
            } else {
              _tmpPortalNotification = _cursor.getString(_cursorIndexOfPortalNotification);
            }
            final boolean _tmpPortalLiveEnabled;
            final int _tmp_11;
            _tmp_11 = _cursor.getInt(_cursorIndexOfPortalLiveEnabled);
            _tmpPortalLiveEnabled = _tmp_11 != 0;
            final String _tmpPortalLiveUrl;
            if (_cursor.isNull(_cursorIndexOfPortalLiveUrl)) {
              _tmpPortalLiveUrl = null;
            } else {
              _tmpPortalLiveUrl = _cursor.getString(_cursorIndexOfPortalLiveUrl);
            }
            final boolean _tmpPortalBreakEnabled;
            final int _tmp_12;
            _tmp_12 = _cursor.getInt(_cursorIndexOfPortalBreakEnabled);
            _tmpPortalBreakEnabled = _tmp_12 != 0;
            final String _tmpPortalBreakUrl;
            if (_cursor.isNull(_cursorIndexOfPortalBreakUrl)) {
              _tmpPortalBreakUrl = null;
            } else {
              _tmpPortalBreakUrl = _cursor.getString(_cursorIndexOfPortalBreakUrl);
            }
            final boolean _tmpPortalSpeedtestEnabled;
            final int _tmp_13;
            _tmp_13 = _cursor.getInt(_cursorIndexOfPortalSpeedtestEnabled);
            _tmpPortalSpeedtestEnabled = _tmp_13 != 0;
            final boolean _tmpMaintenanceEnabled;
            final int _tmp_14;
            _tmp_14 = _cursor.getInt(_cursorIndexOfMaintenanceEnabled);
            _tmpMaintenanceEnabled = _tmp_14 != 0;
            final String _tmpMaintenancePolicy;
            if (_cursor.isNull(_cursorIndexOfMaintenancePolicy)) {
              _tmpMaintenancePolicy = null;
            } else {
              _tmpMaintenancePolicy = _cursor.getString(_cursorIndexOfMaintenancePolicy);
            }
            final String _tmpMaintenanceStartTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceStartTime)) {
              _tmpMaintenanceStartTime = null;
            } else {
              _tmpMaintenanceStartTime = _cursor.getString(_cursorIndexOfMaintenanceStartTime);
            }
            final String _tmpMaintenanceEndTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceEndTime)) {
              _tmpMaintenanceEndTime = null;
            } else {
              _tmpMaintenanceEndTime = _cursor.getString(_cursorIndexOfMaintenanceEndTime);
            }
            final String _tmpAutoupdateStartTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateStartTime)) {
              _tmpAutoupdateStartTime = null;
            } else {
              _tmpAutoupdateStartTime = _cursor.getString(_cursorIndexOfAutoupdateStartTime);
            }
            final String _tmpAutoupdateEndTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateEndTime)) {
              _tmpAutoupdateEndTime = null;
            } else {
              _tmpAutoupdateEndTime = _cursor.getString(_cursorIndexOfAutoupdateEndTime);
            }
            final String _tmpUplinkBand;
            if (_cursor.isNull(_cursorIndexOfUplinkBand)) {
              _tmpUplinkBand = null;
            } else {
              _tmpUplinkBand = _cursor.getString(_cursorIndexOfUplinkBand);
            }
            final String _tmpUplinkSsid;
            if (_cursor.isNull(_cursorIndexOfUplinkSsid)) {
              _tmpUplinkSsid = null;
            } else {
              _tmpUplinkSsid = _cursor.getString(_cursorIndexOfUplinkSsid);
            }
            final String _tmpUplinkKey;
            if (_cursor.isNull(_cursorIndexOfUplinkKey)) {
              _tmpUplinkKey = null;
            } else {
              _tmpUplinkKey = _cursor.getString(_cursorIndexOfUplinkKey);
            }
            final String _tmpMeshBand;
            if (_cursor.isNull(_cursorIndexOfMeshBand)) {
              _tmpMeshBand = null;
            } else {
              _tmpMeshBand = _cursor.getString(_cursorIndexOfMeshBand);
            }
            final String _tmpMeshId;
            if (_cursor.isNull(_cursorIndexOfMeshId)) {
              _tmpMeshId = null;
            } else {
              _tmpMeshId = _cursor.getString(_cursorIndexOfMeshId);
            }
            final String _tmpMeshKey;
            if (_cursor.isNull(_cursorIndexOfMeshKey)) {
              _tmpMeshKey = null;
            } else {
              _tmpMeshKey = _cursor.getString(_cursorIndexOfMeshKey);
            }
            final String _tmpRebootHours;
            if (_cursor.isNull(_cursorIndexOfRebootHours)) {
              _tmpRebootHours = null;
            } else {
              _tmpRebootHours = _cursor.getString(_cursorIndexOfRebootHours);
            }
            final String _tmpVlanSsid2g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid2g)) {
              _tmpVlanSsid2g = null;
            } else {
              _tmpVlanSsid2g = _cursor.getString(_cursorIndexOfVlanSsid2g);
            }
            final String _tmpVlanSsid5g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid5g)) {
              _tmpVlanSsid5g = null;
            } else {
              _tmpVlanSsid5g = _cursor.getString(_cursorIndexOfVlanSsid5g);
            }
            final boolean _tmpVlanSsidIpSuffix;
            final int _tmp_15;
            _tmp_15 = _cursor.getInt(_cursorIndexOfVlanSsidIpSuffix);
            _tmpVlanSsidIpSuffix = _tmp_15 != 0;
            final String _tmpHotspotSecondaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolStart)) {
              _tmpHotspotSecondaryPoolStart = null;
            } else {
              _tmpHotspotSecondaryPoolStart = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolStart);
            }
            final String _tmpHotspotSecondaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolEnd)) {
              _tmpHotspotSecondaryPoolEnd = null;
            } else {
              _tmpHotspotSecondaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolEnd);
            }
            final String _tmpHotspotSecondaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPolicy)) {
              _tmpHotspotSecondaryPolicy = null;
            } else {
              _tmpHotspotSecondaryPolicy = _cursor.getString(_cursorIndexOfHotspotSecondaryPolicy);
            }
            final boolean _tmpHotspotMacAuthEnabled;
            final int _tmp_16;
            _tmp_16 = _cursor.getInt(_cursorIndexOfHotspotMacAuthEnabled);
            _tmpHotspotMacAuthEnabled = _tmp_16 != 0;
            final String _tmpHotspotMacAuthSuffix;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthSuffix)) {
              _tmpHotspotMacAuthSuffix = null;
            } else {
              _tmpHotspotMacAuthSuffix = _cursor.getString(_cursorIndexOfHotspotMacAuthSuffix);
            }
            final String _tmpHotspotMacAuthPassword;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthPassword)) {
              _tmpHotspotMacAuthPassword = null;
            } else {
              _tmpHotspotMacAuthPassword = _cursor.getString(_cursorIndexOfHotspotMacAuthPassword);
            }
            final String _tmpHotspotWalledGarden;
            if (_cursor.isNull(_cursorIndexOfHotspotWalledGarden)) {
              _tmpHotspotWalledGarden = null;
            } else {
              _tmpHotspotWalledGarden = _cursor.getString(_cursorIndexOfHotspotWalledGarden);
            }
            final boolean _tmpHotspotBrowserCookieEnabled;
            final int _tmp_17;
            _tmp_17 = _cursor.getInt(_cursorIndexOfHotspotBrowserCookieEnabled);
            _tmpHotspotBrowserCookieEnabled = _tmp_17 != 0;
            final String _tmpHotspotBrowserCookieDays;
            if (_cursor.isNull(_cursorIndexOfHotspotBrowserCookieDays)) {
              _tmpHotspotBrowserCookieDays = null;
            } else {
              _tmpHotspotBrowserCookieDays = _cursor.getString(_cursorIndexOfHotspotBrowserCookieDays);
            }
            final long _tmpTimestamp;
            _tmpTimestamp = _cursor.getLong(_cursorIndexOfTimestamp);
            final boolean _tmpIsTemplate;
            final int _tmp_18;
            _tmp_18 = _cursor.getInt(_cursorIndexOfIsTemplate);
            _tmpIsTemplate = _tmp_18 != 0;
            _result = new Device(_tmpId,_tmpMacAddress,_tmpDeviceName,_tmpDeviceType,_tmpLanIp,_tmpLanNetmask,_tmpWifiSsid,_tmpWifiKey,_tmpWifiChannel,_tmpWifi2gChannel,_tmpWifi2gMode,_tmpWifi2gWidth,_tmpWifi5gChannel,_tmpWifi5gMode,_tmpWifi5gWidth,_tmpWifi5gNameType,_tmpWifi5gCustomSsid,_tmpAppendIpToSsid,_tmpOtaWindowStart,_tmpOtaWindowEnd,_tmpVlanEnabled,_tmpVlanId,_tmpAppendIpToVlanSsid,_tmpDisableResetButton,_tmpResetPressDuration,_tmpDisableWpsButton,_tmpAutoRebootEnabled,_tmpRootPassword,_tmpHotspotWanInterface,_tmpHotspotSubscriberInterface,_tmpHotspotPrimaryIp,_tmpHotspotPrimaryPoolStart,_tmpHotspotPrimaryPoolEnd,_tmpHotspotPrimaryPolicy,_tmpHotspotDnsName,_tmpHotspotDns1,_tmpHotspotDns2,_tmpHotspotBridgeAgeingTime,_tmpHotspotCardPage,_tmpHotspotRateLimit,_tmpHotspotMacCookie,_tmpHotspotAvailableSpeeds,_tmpHotspotSecondaryEnabled,_tmpHotspotSecondarySsid,_tmpHotspotSecondaryIp,_tmpHotspotTrialEnabled,_tmpHotspotTrialDuration,_tmpHotspotTrialUptimeLimit,_tmpRadiusServer,_tmpRadiusServerBackup,_tmpRadiusSecret,_tmpRadiusAuthPort,_tmpRadiusAcctPort,_tmpRadiusNasIp,_tmpRadiusNasId,_tmpRadiusInterimUpdate,_tmpRadiusCoaEnabled,_tmpRadiusCoaPort,_tmpRestApiEnabled,_tmpRestApiProto,_tmpRestApiUsername,_tmpRestApiPassword,_tmpPortalSupportPhone,_tmpPortalNotification,_tmpPortalLiveEnabled,_tmpPortalLiveUrl,_tmpPortalBreakEnabled,_tmpPortalBreakUrl,_tmpPortalSpeedtestEnabled,_tmpMaintenanceEnabled,_tmpMaintenancePolicy,_tmpMaintenanceStartTime,_tmpMaintenanceEndTime,_tmpAutoupdateStartTime,_tmpAutoupdateEndTime,_tmpUplinkBand,_tmpUplinkSsid,_tmpUplinkKey,_tmpMeshBand,_tmpMeshId,_tmpMeshKey,_tmpRebootHours,_tmpVlanSsid2g,_tmpVlanSsid5g,_tmpVlanSsidIpSuffix,_tmpHotspotSecondaryPoolStart,_tmpHotspotSecondaryPoolEnd,_tmpHotspotSecondaryPolicy,_tmpHotspotMacAuthEnabled,_tmpHotspotMacAuthSuffix,_tmpHotspotMacAuthPassword,_tmpHotspotWalledGarden,_tmpHotspotBrowserCookieEnabled,_tmpHotspotBrowserCookieDays,_tmpTimestamp,_tmpIsTemplate);
          } else {
            _result = null;
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object getDeviceByIp(final String ip, final Continuation<? super Device> $completion) {
    final String _sql = "SELECT * FROM devices WHERE lanIp = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    if (ip == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindString(_argIndex, ip);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Device>() {
      @Override
      @Nullable
      public Device call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfMacAddress = CursorUtil.getColumnIndexOrThrow(_cursor, "macAddress");
          final int _cursorIndexOfDeviceName = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceName");
          final int _cursorIndexOfDeviceType = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceType");
          final int _cursorIndexOfLanIp = CursorUtil.getColumnIndexOrThrow(_cursor, "lanIp");
          final int _cursorIndexOfLanNetmask = CursorUtil.getColumnIndexOrThrow(_cursor, "lanNetmask");
          final int _cursorIndexOfWifiSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiSsid");
          final int _cursorIndexOfWifiKey = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiKey");
          final int _cursorIndexOfWifiChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiChannel");
          final int _cursorIndexOfWifi2gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gChannel");
          final int _cursorIndexOfWifi2gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gMode");
          final int _cursorIndexOfWifi2gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gWidth");
          final int _cursorIndexOfWifi5gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gChannel");
          final int _cursorIndexOfWifi5gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gMode");
          final int _cursorIndexOfWifi5gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gWidth");
          final int _cursorIndexOfWifi5gNameType = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gNameType");
          final int _cursorIndexOfWifi5gCustomSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gCustomSsid");
          final int _cursorIndexOfAppendIpToSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToSsid");
          final int _cursorIndexOfOtaWindowStart = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowStart");
          final int _cursorIndexOfOtaWindowEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowEnd");
          final int _cursorIndexOfVlanEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanEnabled");
          final int _cursorIndexOfVlanId = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanId");
          final int _cursorIndexOfAppendIpToVlanSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToVlanSsid");
          final int _cursorIndexOfDisableResetButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableResetButton");
          final int _cursorIndexOfResetPressDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "resetPressDuration");
          final int _cursorIndexOfDisableWpsButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableWpsButton");
          final int _cursorIndexOfAutoRebootEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "autoRebootEnabled");
          final int _cursorIndexOfRootPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "rootPassword");
          final int _cursorIndexOfHotspotWanInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWanInterface");
          final int _cursorIndexOfHotspotSubscriberInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSubscriberInterface");
          final int _cursorIndexOfHotspotPrimaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryIp");
          final int _cursorIndexOfHotspotPrimaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolStart");
          final int _cursorIndexOfHotspotPrimaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolEnd");
          final int _cursorIndexOfHotspotPrimaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPolicy");
          final int _cursorIndexOfHotspotDnsName = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDnsName");
          final int _cursorIndexOfHotspotDns1 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns1");
          final int _cursorIndexOfHotspotDns2 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns2");
          final int _cursorIndexOfHotspotBridgeAgeingTime = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBridgeAgeingTime");
          final int _cursorIndexOfHotspotCardPage = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotCardPage");
          final int _cursorIndexOfHotspotRateLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotRateLimit");
          final int _cursorIndexOfHotspotMacCookie = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacCookie");
          final int _cursorIndexOfHotspotAvailableSpeeds = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotAvailableSpeeds");
          final int _cursorIndexOfHotspotSecondaryEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryEnabled");
          final int _cursorIndexOfHotspotSecondarySsid = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondarySsid");
          final int _cursorIndexOfHotspotSecondaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryIp");
          final int _cursorIndexOfHotspotTrialEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialEnabled");
          final int _cursorIndexOfHotspotTrialDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialDuration");
          final int _cursorIndexOfHotspotTrialUptimeLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialUptimeLimit");
          final int _cursorIndexOfRadiusServer = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServer");
          final int _cursorIndexOfRadiusServerBackup = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServerBackup");
          final int _cursorIndexOfRadiusSecret = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusSecret");
          final int _cursorIndexOfRadiusAuthPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAuthPort");
          final int _cursorIndexOfRadiusAcctPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAcctPort");
          final int _cursorIndexOfRadiusNasIp = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasIp");
          final int _cursorIndexOfRadiusNasId = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasId");
          final int _cursorIndexOfRadiusInterimUpdate = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusInterimUpdate");
          final int _cursorIndexOfRadiusCoaEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaEnabled");
          final int _cursorIndexOfRadiusCoaPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaPort");
          final int _cursorIndexOfRestApiEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiEnabled");
          final int _cursorIndexOfRestApiProto = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiProto");
          final int _cursorIndexOfRestApiUsername = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiUsername");
          final int _cursorIndexOfRestApiPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiPassword");
          final int _cursorIndexOfPortalSupportPhone = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSupportPhone");
          final int _cursorIndexOfPortalNotification = CursorUtil.getColumnIndexOrThrow(_cursor, "portalNotification");
          final int _cursorIndexOfPortalLiveEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveEnabled");
          final int _cursorIndexOfPortalLiveUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveUrl");
          final int _cursorIndexOfPortalBreakEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakEnabled");
          final int _cursorIndexOfPortalBreakUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakUrl");
          final int _cursorIndexOfPortalSpeedtestEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSpeedtestEnabled");
          final int _cursorIndexOfMaintenanceEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEnabled");
          final int _cursorIndexOfMaintenancePolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenancePolicy");
          final int _cursorIndexOfMaintenanceStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceStartTime");
          final int _cursorIndexOfMaintenanceEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEndTime");
          final int _cursorIndexOfAutoupdateStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateStartTime");
          final int _cursorIndexOfAutoupdateEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateEndTime");
          final int _cursorIndexOfUplinkBand = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkBand");
          final int _cursorIndexOfUplinkSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkSsid");
          final int _cursorIndexOfUplinkKey = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkKey");
          final int _cursorIndexOfMeshBand = CursorUtil.getColumnIndexOrThrow(_cursor, "meshBand");
          final int _cursorIndexOfMeshId = CursorUtil.getColumnIndexOrThrow(_cursor, "meshId");
          final int _cursorIndexOfMeshKey = CursorUtil.getColumnIndexOrThrow(_cursor, "meshKey");
          final int _cursorIndexOfRebootHours = CursorUtil.getColumnIndexOrThrow(_cursor, "rebootHours");
          final int _cursorIndexOfVlanSsid2g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid2g");
          final int _cursorIndexOfVlanSsid5g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid5g");
          final int _cursorIndexOfVlanSsidIpSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsidIpSuffix");
          final int _cursorIndexOfHotspotSecondaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolStart");
          final int _cursorIndexOfHotspotSecondaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolEnd");
          final int _cursorIndexOfHotspotSecondaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPolicy");
          final int _cursorIndexOfHotspotMacAuthEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthEnabled");
          final int _cursorIndexOfHotspotMacAuthSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthSuffix");
          final int _cursorIndexOfHotspotMacAuthPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthPassword");
          final int _cursorIndexOfHotspotWalledGarden = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWalledGarden");
          final int _cursorIndexOfHotspotBrowserCookieEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieEnabled");
          final int _cursorIndexOfHotspotBrowserCookieDays = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieDays");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfIsTemplate = CursorUtil.getColumnIndexOrThrow(_cursor, "isTemplate");
          final Device _result;
          if (_cursor.moveToFirst()) {
            final int _tmpId;
            _tmpId = _cursor.getInt(_cursorIndexOfId);
            final String _tmpMacAddress;
            if (_cursor.isNull(_cursorIndexOfMacAddress)) {
              _tmpMacAddress = null;
            } else {
              _tmpMacAddress = _cursor.getString(_cursorIndexOfMacAddress);
            }
            final String _tmpDeviceName;
            if (_cursor.isNull(_cursorIndexOfDeviceName)) {
              _tmpDeviceName = null;
            } else {
              _tmpDeviceName = _cursor.getString(_cursorIndexOfDeviceName);
            }
            final String _tmpDeviceType;
            if (_cursor.isNull(_cursorIndexOfDeviceType)) {
              _tmpDeviceType = null;
            } else {
              _tmpDeviceType = _cursor.getString(_cursorIndexOfDeviceType);
            }
            final String _tmpLanIp;
            if (_cursor.isNull(_cursorIndexOfLanIp)) {
              _tmpLanIp = null;
            } else {
              _tmpLanIp = _cursor.getString(_cursorIndexOfLanIp);
            }
            final String _tmpLanNetmask;
            if (_cursor.isNull(_cursorIndexOfLanNetmask)) {
              _tmpLanNetmask = null;
            } else {
              _tmpLanNetmask = _cursor.getString(_cursorIndexOfLanNetmask);
            }
            final String _tmpWifiSsid;
            if (_cursor.isNull(_cursorIndexOfWifiSsid)) {
              _tmpWifiSsid = null;
            } else {
              _tmpWifiSsid = _cursor.getString(_cursorIndexOfWifiSsid);
            }
            final String _tmpWifiKey;
            if (_cursor.isNull(_cursorIndexOfWifiKey)) {
              _tmpWifiKey = null;
            } else {
              _tmpWifiKey = _cursor.getString(_cursorIndexOfWifiKey);
            }
            final String _tmpWifiChannel;
            if (_cursor.isNull(_cursorIndexOfWifiChannel)) {
              _tmpWifiChannel = null;
            } else {
              _tmpWifiChannel = _cursor.getString(_cursorIndexOfWifiChannel);
            }
            final String _tmpWifi2gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi2gChannel)) {
              _tmpWifi2gChannel = null;
            } else {
              _tmpWifi2gChannel = _cursor.getString(_cursorIndexOfWifi2gChannel);
            }
            final String _tmpWifi2gMode;
            if (_cursor.isNull(_cursorIndexOfWifi2gMode)) {
              _tmpWifi2gMode = null;
            } else {
              _tmpWifi2gMode = _cursor.getString(_cursorIndexOfWifi2gMode);
            }
            final String _tmpWifi2gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi2gWidth)) {
              _tmpWifi2gWidth = null;
            } else {
              _tmpWifi2gWidth = _cursor.getString(_cursorIndexOfWifi2gWidth);
            }
            final String _tmpWifi5gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi5gChannel)) {
              _tmpWifi5gChannel = null;
            } else {
              _tmpWifi5gChannel = _cursor.getString(_cursorIndexOfWifi5gChannel);
            }
            final String _tmpWifi5gMode;
            if (_cursor.isNull(_cursorIndexOfWifi5gMode)) {
              _tmpWifi5gMode = null;
            } else {
              _tmpWifi5gMode = _cursor.getString(_cursorIndexOfWifi5gMode);
            }
            final String _tmpWifi5gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi5gWidth)) {
              _tmpWifi5gWidth = null;
            } else {
              _tmpWifi5gWidth = _cursor.getString(_cursorIndexOfWifi5gWidth);
            }
            final String _tmpWifi5gNameType;
            if (_cursor.isNull(_cursorIndexOfWifi5gNameType)) {
              _tmpWifi5gNameType = null;
            } else {
              _tmpWifi5gNameType = _cursor.getString(_cursorIndexOfWifi5gNameType);
            }
            final String _tmpWifi5gCustomSsid;
            if (_cursor.isNull(_cursorIndexOfWifi5gCustomSsid)) {
              _tmpWifi5gCustomSsid = null;
            } else {
              _tmpWifi5gCustomSsid = _cursor.getString(_cursorIndexOfWifi5gCustomSsid);
            }
            final boolean _tmpAppendIpToSsid;
            final int _tmp;
            _tmp = _cursor.getInt(_cursorIndexOfAppendIpToSsid);
            _tmpAppendIpToSsid = _tmp != 0;
            final String _tmpOtaWindowStart;
            if (_cursor.isNull(_cursorIndexOfOtaWindowStart)) {
              _tmpOtaWindowStart = null;
            } else {
              _tmpOtaWindowStart = _cursor.getString(_cursorIndexOfOtaWindowStart);
            }
            final String _tmpOtaWindowEnd;
            if (_cursor.isNull(_cursorIndexOfOtaWindowEnd)) {
              _tmpOtaWindowEnd = null;
            } else {
              _tmpOtaWindowEnd = _cursor.getString(_cursorIndexOfOtaWindowEnd);
            }
            final boolean _tmpVlanEnabled;
            final int _tmp_1;
            _tmp_1 = _cursor.getInt(_cursorIndexOfVlanEnabled);
            _tmpVlanEnabled = _tmp_1 != 0;
            final String _tmpVlanId;
            if (_cursor.isNull(_cursorIndexOfVlanId)) {
              _tmpVlanId = null;
            } else {
              _tmpVlanId = _cursor.getString(_cursorIndexOfVlanId);
            }
            final boolean _tmpAppendIpToVlanSsid;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfAppendIpToVlanSsid);
            _tmpAppendIpToVlanSsid = _tmp_2 != 0;
            final boolean _tmpDisableResetButton;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfDisableResetButton);
            _tmpDisableResetButton = _tmp_3 != 0;
            final String _tmpResetPressDuration;
            if (_cursor.isNull(_cursorIndexOfResetPressDuration)) {
              _tmpResetPressDuration = null;
            } else {
              _tmpResetPressDuration = _cursor.getString(_cursorIndexOfResetPressDuration);
            }
            final boolean _tmpDisableWpsButton;
            final int _tmp_4;
            _tmp_4 = _cursor.getInt(_cursorIndexOfDisableWpsButton);
            _tmpDisableWpsButton = _tmp_4 != 0;
            final boolean _tmpAutoRebootEnabled;
            final int _tmp_5;
            _tmp_5 = _cursor.getInt(_cursorIndexOfAutoRebootEnabled);
            _tmpAutoRebootEnabled = _tmp_5 != 0;
            final String _tmpRootPassword;
            if (_cursor.isNull(_cursorIndexOfRootPassword)) {
              _tmpRootPassword = null;
            } else {
              _tmpRootPassword = _cursor.getString(_cursorIndexOfRootPassword);
            }
            final String _tmpHotspotWanInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotWanInterface)) {
              _tmpHotspotWanInterface = null;
            } else {
              _tmpHotspotWanInterface = _cursor.getString(_cursorIndexOfHotspotWanInterface);
            }
            final String _tmpHotspotSubscriberInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotSubscriberInterface)) {
              _tmpHotspotSubscriberInterface = null;
            } else {
              _tmpHotspotSubscriberInterface = _cursor.getString(_cursorIndexOfHotspotSubscriberInterface);
            }
            final String _tmpHotspotPrimaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryIp)) {
              _tmpHotspotPrimaryIp = null;
            } else {
              _tmpHotspotPrimaryIp = _cursor.getString(_cursorIndexOfHotspotPrimaryIp);
            }
            final String _tmpHotspotPrimaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolStart)) {
              _tmpHotspotPrimaryPoolStart = null;
            } else {
              _tmpHotspotPrimaryPoolStart = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolStart);
            }
            final String _tmpHotspotPrimaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolEnd)) {
              _tmpHotspotPrimaryPoolEnd = null;
            } else {
              _tmpHotspotPrimaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolEnd);
            }
            final String _tmpHotspotPrimaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPolicy)) {
              _tmpHotspotPrimaryPolicy = null;
            } else {
              _tmpHotspotPrimaryPolicy = _cursor.getString(_cursorIndexOfHotspotPrimaryPolicy);
            }
            final String _tmpHotspotDnsName;
            if (_cursor.isNull(_cursorIndexOfHotspotDnsName)) {
              _tmpHotspotDnsName = null;
            } else {
              _tmpHotspotDnsName = _cursor.getString(_cursorIndexOfHotspotDnsName);
            }
            final String _tmpHotspotDns1;
            if (_cursor.isNull(_cursorIndexOfHotspotDns1)) {
              _tmpHotspotDns1 = null;
            } else {
              _tmpHotspotDns1 = _cursor.getString(_cursorIndexOfHotspotDns1);
            }
            final String _tmpHotspotDns2;
            if (_cursor.isNull(_cursorIndexOfHotspotDns2)) {
              _tmpHotspotDns2 = null;
            } else {
              _tmpHotspotDns2 = _cursor.getString(_cursorIndexOfHotspotDns2);
            }
            final String _tmpHotspotBridgeAgeingTime;
            if (_cursor.isNull(_cursorIndexOfHotspotBridgeAgeingTime)) {
              _tmpHotspotBridgeAgeingTime = null;
            } else {
              _tmpHotspotBridgeAgeingTime = _cursor.getString(_cursorIndexOfHotspotBridgeAgeingTime);
            }
            final String _tmpHotspotCardPage;
            if (_cursor.isNull(_cursorIndexOfHotspotCardPage)) {
              _tmpHotspotCardPage = null;
            } else {
              _tmpHotspotCardPage = _cursor.getString(_cursorIndexOfHotspotCardPage);
            }
            final String _tmpHotspotRateLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotRateLimit)) {
              _tmpHotspotRateLimit = null;
            } else {
              _tmpHotspotRateLimit = _cursor.getString(_cursorIndexOfHotspotRateLimit);
            }
            final boolean _tmpHotspotMacCookie;
            final int _tmp_6;
            _tmp_6 = _cursor.getInt(_cursorIndexOfHotspotMacCookie);
            _tmpHotspotMacCookie = _tmp_6 != 0;
            final String _tmpHotspotAvailableSpeeds;
            if (_cursor.isNull(_cursorIndexOfHotspotAvailableSpeeds)) {
              _tmpHotspotAvailableSpeeds = null;
            } else {
              _tmpHotspotAvailableSpeeds = _cursor.getString(_cursorIndexOfHotspotAvailableSpeeds);
            }
            final boolean _tmpHotspotSecondaryEnabled;
            final int _tmp_7;
            _tmp_7 = _cursor.getInt(_cursorIndexOfHotspotSecondaryEnabled);
            _tmpHotspotSecondaryEnabled = _tmp_7 != 0;
            final String _tmpHotspotSecondarySsid;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondarySsid)) {
              _tmpHotspotSecondarySsid = null;
            } else {
              _tmpHotspotSecondarySsid = _cursor.getString(_cursorIndexOfHotspotSecondarySsid);
            }
            final String _tmpHotspotSecondaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryIp)) {
              _tmpHotspotSecondaryIp = null;
            } else {
              _tmpHotspotSecondaryIp = _cursor.getString(_cursorIndexOfHotspotSecondaryIp);
            }
            final boolean _tmpHotspotTrialEnabled;
            final int _tmp_8;
            _tmp_8 = _cursor.getInt(_cursorIndexOfHotspotTrialEnabled);
            _tmpHotspotTrialEnabled = _tmp_8 != 0;
            final String _tmpHotspotTrialDuration;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialDuration)) {
              _tmpHotspotTrialDuration = null;
            } else {
              _tmpHotspotTrialDuration = _cursor.getString(_cursorIndexOfHotspotTrialDuration);
            }
            final String _tmpHotspotTrialUptimeLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialUptimeLimit)) {
              _tmpHotspotTrialUptimeLimit = null;
            } else {
              _tmpHotspotTrialUptimeLimit = _cursor.getString(_cursorIndexOfHotspotTrialUptimeLimit);
            }
            final String _tmpRadiusServer;
            if (_cursor.isNull(_cursorIndexOfRadiusServer)) {
              _tmpRadiusServer = null;
            } else {
              _tmpRadiusServer = _cursor.getString(_cursorIndexOfRadiusServer);
            }
            final String _tmpRadiusServerBackup;
            if (_cursor.isNull(_cursorIndexOfRadiusServerBackup)) {
              _tmpRadiusServerBackup = null;
            } else {
              _tmpRadiusServerBackup = _cursor.getString(_cursorIndexOfRadiusServerBackup);
            }
            final String _tmpRadiusSecret;
            if (_cursor.isNull(_cursorIndexOfRadiusSecret)) {
              _tmpRadiusSecret = null;
            } else {
              _tmpRadiusSecret = _cursor.getString(_cursorIndexOfRadiusSecret);
            }
            final String _tmpRadiusAuthPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAuthPort)) {
              _tmpRadiusAuthPort = null;
            } else {
              _tmpRadiusAuthPort = _cursor.getString(_cursorIndexOfRadiusAuthPort);
            }
            final String _tmpRadiusAcctPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAcctPort)) {
              _tmpRadiusAcctPort = null;
            } else {
              _tmpRadiusAcctPort = _cursor.getString(_cursorIndexOfRadiusAcctPort);
            }
            final String _tmpRadiusNasIp;
            if (_cursor.isNull(_cursorIndexOfRadiusNasIp)) {
              _tmpRadiusNasIp = null;
            } else {
              _tmpRadiusNasIp = _cursor.getString(_cursorIndexOfRadiusNasIp);
            }
            final String _tmpRadiusNasId;
            if (_cursor.isNull(_cursorIndexOfRadiusNasId)) {
              _tmpRadiusNasId = null;
            } else {
              _tmpRadiusNasId = _cursor.getString(_cursorIndexOfRadiusNasId);
            }
            final String _tmpRadiusInterimUpdate;
            if (_cursor.isNull(_cursorIndexOfRadiusInterimUpdate)) {
              _tmpRadiusInterimUpdate = null;
            } else {
              _tmpRadiusInterimUpdate = _cursor.getString(_cursorIndexOfRadiusInterimUpdate);
            }
            final boolean _tmpRadiusCoaEnabled;
            final int _tmp_9;
            _tmp_9 = _cursor.getInt(_cursorIndexOfRadiusCoaEnabled);
            _tmpRadiusCoaEnabled = _tmp_9 != 0;
            final String _tmpRadiusCoaPort;
            if (_cursor.isNull(_cursorIndexOfRadiusCoaPort)) {
              _tmpRadiusCoaPort = null;
            } else {
              _tmpRadiusCoaPort = _cursor.getString(_cursorIndexOfRadiusCoaPort);
            }
            final boolean _tmpRestApiEnabled;
            final int _tmp_10;
            _tmp_10 = _cursor.getInt(_cursorIndexOfRestApiEnabled);
            _tmpRestApiEnabled = _tmp_10 != 0;
            final String _tmpRestApiProto;
            if (_cursor.isNull(_cursorIndexOfRestApiProto)) {
              _tmpRestApiProto = null;
            } else {
              _tmpRestApiProto = _cursor.getString(_cursorIndexOfRestApiProto);
            }
            final String _tmpRestApiUsername;
            if (_cursor.isNull(_cursorIndexOfRestApiUsername)) {
              _tmpRestApiUsername = null;
            } else {
              _tmpRestApiUsername = _cursor.getString(_cursorIndexOfRestApiUsername);
            }
            final String _tmpRestApiPassword;
            if (_cursor.isNull(_cursorIndexOfRestApiPassword)) {
              _tmpRestApiPassword = null;
            } else {
              _tmpRestApiPassword = _cursor.getString(_cursorIndexOfRestApiPassword);
            }
            final String _tmpPortalSupportPhone;
            if (_cursor.isNull(_cursorIndexOfPortalSupportPhone)) {
              _tmpPortalSupportPhone = null;
            } else {
              _tmpPortalSupportPhone = _cursor.getString(_cursorIndexOfPortalSupportPhone);
            }
            final String _tmpPortalNotification;
            if (_cursor.isNull(_cursorIndexOfPortalNotification)) {
              _tmpPortalNotification = null;
            } else {
              _tmpPortalNotification = _cursor.getString(_cursorIndexOfPortalNotification);
            }
            final boolean _tmpPortalLiveEnabled;
            final int _tmp_11;
            _tmp_11 = _cursor.getInt(_cursorIndexOfPortalLiveEnabled);
            _tmpPortalLiveEnabled = _tmp_11 != 0;
            final String _tmpPortalLiveUrl;
            if (_cursor.isNull(_cursorIndexOfPortalLiveUrl)) {
              _tmpPortalLiveUrl = null;
            } else {
              _tmpPortalLiveUrl = _cursor.getString(_cursorIndexOfPortalLiveUrl);
            }
            final boolean _tmpPortalBreakEnabled;
            final int _tmp_12;
            _tmp_12 = _cursor.getInt(_cursorIndexOfPortalBreakEnabled);
            _tmpPortalBreakEnabled = _tmp_12 != 0;
            final String _tmpPortalBreakUrl;
            if (_cursor.isNull(_cursorIndexOfPortalBreakUrl)) {
              _tmpPortalBreakUrl = null;
            } else {
              _tmpPortalBreakUrl = _cursor.getString(_cursorIndexOfPortalBreakUrl);
            }
            final boolean _tmpPortalSpeedtestEnabled;
            final int _tmp_13;
            _tmp_13 = _cursor.getInt(_cursorIndexOfPortalSpeedtestEnabled);
            _tmpPortalSpeedtestEnabled = _tmp_13 != 0;
            final boolean _tmpMaintenanceEnabled;
            final int _tmp_14;
            _tmp_14 = _cursor.getInt(_cursorIndexOfMaintenanceEnabled);
            _tmpMaintenanceEnabled = _tmp_14 != 0;
            final String _tmpMaintenancePolicy;
            if (_cursor.isNull(_cursorIndexOfMaintenancePolicy)) {
              _tmpMaintenancePolicy = null;
            } else {
              _tmpMaintenancePolicy = _cursor.getString(_cursorIndexOfMaintenancePolicy);
            }
            final String _tmpMaintenanceStartTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceStartTime)) {
              _tmpMaintenanceStartTime = null;
            } else {
              _tmpMaintenanceStartTime = _cursor.getString(_cursorIndexOfMaintenanceStartTime);
            }
            final String _tmpMaintenanceEndTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceEndTime)) {
              _tmpMaintenanceEndTime = null;
            } else {
              _tmpMaintenanceEndTime = _cursor.getString(_cursorIndexOfMaintenanceEndTime);
            }
            final String _tmpAutoupdateStartTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateStartTime)) {
              _tmpAutoupdateStartTime = null;
            } else {
              _tmpAutoupdateStartTime = _cursor.getString(_cursorIndexOfAutoupdateStartTime);
            }
            final String _tmpAutoupdateEndTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateEndTime)) {
              _tmpAutoupdateEndTime = null;
            } else {
              _tmpAutoupdateEndTime = _cursor.getString(_cursorIndexOfAutoupdateEndTime);
            }
            final String _tmpUplinkBand;
            if (_cursor.isNull(_cursorIndexOfUplinkBand)) {
              _tmpUplinkBand = null;
            } else {
              _tmpUplinkBand = _cursor.getString(_cursorIndexOfUplinkBand);
            }
            final String _tmpUplinkSsid;
            if (_cursor.isNull(_cursorIndexOfUplinkSsid)) {
              _tmpUplinkSsid = null;
            } else {
              _tmpUplinkSsid = _cursor.getString(_cursorIndexOfUplinkSsid);
            }
            final String _tmpUplinkKey;
            if (_cursor.isNull(_cursorIndexOfUplinkKey)) {
              _tmpUplinkKey = null;
            } else {
              _tmpUplinkKey = _cursor.getString(_cursorIndexOfUplinkKey);
            }
            final String _tmpMeshBand;
            if (_cursor.isNull(_cursorIndexOfMeshBand)) {
              _tmpMeshBand = null;
            } else {
              _tmpMeshBand = _cursor.getString(_cursorIndexOfMeshBand);
            }
            final String _tmpMeshId;
            if (_cursor.isNull(_cursorIndexOfMeshId)) {
              _tmpMeshId = null;
            } else {
              _tmpMeshId = _cursor.getString(_cursorIndexOfMeshId);
            }
            final String _tmpMeshKey;
            if (_cursor.isNull(_cursorIndexOfMeshKey)) {
              _tmpMeshKey = null;
            } else {
              _tmpMeshKey = _cursor.getString(_cursorIndexOfMeshKey);
            }
            final String _tmpRebootHours;
            if (_cursor.isNull(_cursorIndexOfRebootHours)) {
              _tmpRebootHours = null;
            } else {
              _tmpRebootHours = _cursor.getString(_cursorIndexOfRebootHours);
            }
            final String _tmpVlanSsid2g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid2g)) {
              _tmpVlanSsid2g = null;
            } else {
              _tmpVlanSsid2g = _cursor.getString(_cursorIndexOfVlanSsid2g);
            }
            final String _tmpVlanSsid5g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid5g)) {
              _tmpVlanSsid5g = null;
            } else {
              _tmpVlanSsid5g = _cursor.getString(_cursorIndexOfVlanSsid5g);
            }
            final boolean _tmpVlanSsidIpSuffix;
            final int _tmp_15;
            _tmp_15 = _cursor.getInt(_cursorIndexOfVlanSsidIpSuffix);
            _tmpVlanSsidIpSuffix = _tmp_15 != 0;
            final String _tmpHotspotSecondaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolStart)) {
              _tmpHotspotSecondaryPoolStart = null;
            } else {
              _tmpHotspotSecondaryPoolStart = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolStart);
            }
            final String _tmpHotspotSecondaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolEnd)) {
              _tmpHotspotSecondaryPoolEnd = null;
            } else {
              _tmpHotspotSecondaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolEnd);
            }
            final String _tmpHotspotSecondaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPolicy)) {
              _tmpHotspotSecondaryPolicy = null;
            } else {
              _tmpHotspotSecondaryPolicy = _cursor.getString(_cursorIndexOfHotspotSecondaryPolicy);
            }
            final boolean _tmpHotspotMacAuthEnabled;
            final int _tmp_16;
            _tmp_16 = _cursor.getInt(_cursorIndexOfHotspotMacAuthEnabled);
            _tmpHotspotMacAuthEnabled = _tmp_16 != 0;
            final String _tmpHotspotMacAuthSuffix;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthSuffix)) {
              _tmpHotspotMacAuthSuffix = null;
            } else {
              _tmpHotspotMacAuthSuffix = _cursor.getString(_cursorIndexOfHotspotMacAuthSuffix);
            }
            final String _tmpHotspotMacAuthPassword;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthPassword)) {
              _tmpHotspotMacAuthPassword = null;
            } else {
              _tmpHotspotMacAuthPassword = _cursor.getString(_cursorIndexOfHotspotMacAuthPassword);
            }
            final String _tmpHotspotWalledGarden;
            if (_cursor.isNull(_cursorIndexOfHotspotWalledGarden)) {
              _tmpHotspotWalledGarden = null;
            } else {
              _tmpHotspotWalledGarden = _cursor.getString(_cursorIndexOfHotspotWalledGarden);
            }
            final boolean _tmpHotspotBrowserCookieEnabled;
            final int _tmp_17;
            _tmp_17 = _cursor.getInt(_cursorIndexOfHotspotBrowserCookieEnabled);
            _tmpHotspotBrowserCookieEnabled = _tmp_17 != 0;
            final String _tmpHotspotBrowserCookieDays;
            if (_cursor.isNull(_cursorIndexOfHotspotBrowserCookieDays)) {
              _tmpHotspotBrowserCookieDays = null;
            } else {
              _tmpHotspotBrowserCookieDays = _cursor.getString(_cursorIndexOfHotspotBrowserCookieDays);
            }
            final long _tmpTimestamp;
            _tmpTimestamp = _cursor.getLong(_cursorIndexOfTimestamp);
            final boolean _tmpIsTemplate;
            final int _tmp_18;
            _tmp_18 = _cursor.getInt(_cursorIndexOfIsTemplate);
            _tmpIsTemplate = _tmp_18 != 0;
            _result = new Device(_tmpId,_tmpMacAddress,_tmpDeviceName,_tmpDeviceType,_tmpLanIp,_tmpLanNetmask,_tmpWifiSsid,_tmpWifiKey,_tmpWifiChannel,_tmpWifi2gChannel,_tmpWifi2gMode,_tmpWifi2gWidth,_tmpWifi5gChannel,_tmpWifi5gMode,_tmpWifi5gWidth,_tmpWifi5gNameType,_tmpWifi5gCustomSsid,_tmpAppendIpToSsid,_tmpOtaWindowStart,_tmpOtaWindowEnd,_tmpVlanEnabled,_tmpVlanId,_tmpAppendIpToVlanSsid,_tmpDisableResetButton,_tmpResetPressDuration,_tmpDisableWpsButton,_tmpAutoRebootEnabled,_tmpRootPassword,_tmpHotspotWanInterface,_tmpHotspotSubscriberInterface,_tmpHotspotPrimaryIp,_tmpHotspotPrimaryPoolStart,_tmpHotspotPrimaryPoolEnd,_tmpHotspotPrimaryPolicy,_tmpHotspotDnsName,_tmpHotspotDns1,_tmpHotspotDns2,_tmpHotspotBridgeAgeingTime,_tmpHotspotCardPage,_tmpHotspotRateLimit,_tmpHotspotMacCookie,_tmpHotspotAvailableSpeeds,_tmpHotspotSecondaryEnabled,_tmpHotspotSecondarySsid,_tmpHotspotSecondaryIp,_tmpHotspotTrialEnabled,_tmpHotspotTrialDuration,_tmpHotspotTrialUptimeLimit,_tmpRadiusServer,_tmpRadiusServerBackup,_tmpRadiusSecret,_tmpRadiusAuthPort,_tmpRadiusAcctPort,_tmpRadiusNasIp,_tmpRadiusNasId,_tmpRadiusInterimUpdate,_tmpRadiusCoaEnabled,_tmpRadiusCoaPort,_tmpRestApiEnabled,_tmpRestApiProto,_tmpRestApiUsername,_tmpRestApiPassword,_tmpPortalSupportPhone,_tmpPortalNotification,_tmpPortalLiveEnabled,_tmpPortalLiveUrl,_tmpPortalBreakEnabled,_tmpPortalBreakUrl,_tmpPortalSpeedtestEnabled,_tmpMaintenanceEnabled,_tmpMaintenancePolicy,_tmpMaintenanceStartTime,_tmpMaintenanceEndTime,_tmpAutoupdateStartTime,_tmpAutoupdateEndTime,_tmpUplinkBand,_tmpUplinkSsid,_tmpUplinkKey,_tmpMeshBand,_tmpMeshId,_tmpMeshKey,_tmpRebootHours,_tmpVlanSsid2g,_tmpVlanSsid5g,_tmpVlanSsidIpSuffix,_tmpHotspotSecondaryPoolStart,_tmpHotspotSecondaryPoolEnd,_tmpHotspotSecondaryPolicy,_tmpHotspotMacAuthEnabled,_tmpHotspotMacAuthSuffix,_tmpHotspotMacAuthPassword,_tmpHotspotWalledGarden,_tmpHotspotBrowserCookieEnabled,_tmpHotspotBrowserCookieDays,_tmpTimestamp,_tmpIsTemplate);
          } else {
            _result = null;
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object getLastTemplate(final Continuation<? super Device> $completion) {
    final String _sql = "SELECT * FROM devices WHERE isTemplate = 1 ORDER BY timestamp DESC LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Device>() {
      @Override
      @Nullable
      public Device call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfMacAddress = CursorUtil.getColumnIndexOrThrow(_cursor, "macAddress");
          final int _cursorIndexOfDeviceName = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceName");
          final int _cursorIndexOfDeviceType = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceType");
          final int _cursorIndexOfLanIp = CursorUtil.getColumnIndexOrThrow(_cursor, "lanIp");
          final int _cursorIndexOfLanNetmask = CursorUtil.getColumnIndexOrThrow(_cursor, "lanNetmask");
          final int _cursorIndexOfWifiSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiSsid");
          final int _cursorIndexOfWifiKey = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiKey");
          final int _cursorIndexOfWifiChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifiChannel");
          final int _cursorIndexOfWifi2gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gChannel");
          final int _cursorIndexOfWifi2gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gMode");
          final int _cursorIndexOfWifi2gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi2gWidth");
          final int _cursorIndexOfWifi5gChannel = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gChannel");
          final int _cursorIndexOfWifi5gMode = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gMode");
          final int _cursorIndexOfWifi5gWidth = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gWidth");
          final int _cursorIndexOfWifi5gNameType = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gNameType");
          final int _cursorIndexOfWifi5gCustomSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "wifi5gCustomSsid");
          final int _cursorIndexOfAppendIpToSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToSsid");
          final int _cursorIndexOfOtaWindowStart = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowStart");
          final int _cursorIndexOfOtaWindowEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "otaWindowEnd");
          final int _cursorIndexOfVlanEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanEnabled");
          final int _cursorIndexOfVlanId = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanId");
          final int _cursorIndexOfAppendIpToVlanSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "appendIpToVlanSsid");
          final int _cursorIndexOfDisableResetButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableResetButton");
          final int _cursorIndexOfResetPressDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "resetPressDuration");
          final int _cursorIndexOfDisableWpsButton = CursorUtil.getColumnIndexOrThrow(_cursor, "disableWpsButton");
          final int _cursorIndexOfAutoRebootEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "autoRebootEnabled");
          final int _cursorIndexOfRootPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "rootPassword");
          final int _cursorIndexOfHotspotWanInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWanInterface");
          final int _cursorIndexOfHotspotSubscriberInterface = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSubscriberInterface");
          final int _cursorIndexOfHotspotPrimaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryIp");
          final int _cursorIndexOfHotspotPrimaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolStart");
          final int _cursorIndexOfHotspotPrimaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPoolEnd");
          final int _cursorIndexOfHotspotPrimaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotPrimaryPolicy");
          final int _cursorIndexOfHotspotDnsName = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDnsName");
          final int _cursorIndexOfHotspotDns1 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns1");
          final int _cursorIndexOfHotspotDns2 = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotDns2");
          final int _cursorIndexOfHotspotBridgeAgeingTime = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBridgeAgeingTime");
          final int _cursorIndexOfHotspotCardPage = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotCardPage");
          final int _cursorIndexOfHotspotRateLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotRateLimit");
          final int _cursorIndexOfHotspotMacCookie = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacCookie");
          final int _cursorIndexOfHotspotAvailableSpeeds = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotAvailableSpeeds");
          final int _cursorIndexOfHotspotSecondaryEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryEnabled");
          final int _cursorIndexOfHotspotSecondarySsid = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondarySsid");
          final int _cursorIndexOfHotspotSecondaryIp = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryIp");
          final int _cursorIndexOfHotspotTrialEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialEnabled");
          final int _cursorIndexOfHotspotTrialDuration = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialDuration");
          final int _cursorIndexOfHotspotTrialUptimeLimit = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotTrialUptimeLimit");
          final int _cursorIndexOfRadiusServer = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServer");
          final int _cursorIndexOfRadiusServerBackup = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusServerBackup");
          final int _cursorIndexOfRadiusSecret = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusSecret");
          final int _cursorIndexOfRadiusAuthPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAuthPort");
          final int _cursorIndexOfRadiusAcctPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusAcctPort");
          final int _cursorIndexOfRadiusNasIp = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasIp");
          final int _cursorIndexOfRadiusNasId = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusNasId");
          final int _cursorIndexOfRadiusInterimUpdate = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusInterimUpdate");
          final int _cursorIndexOfRadiusCoaEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaEnabled");
          final int _cursorIndexOfRadiusCoaPort = CursorUtil.getColumnIndexOrThrow(_cursor, "radiusCoaPort");
          final int _cursorIndexOfRestApiEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiEnabled");
          final int _cursorIndexOfRestApiProto = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiProto");
          final int _cursorIndexOfRestApiUsername = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiUsername");
          final int _cursorIndexOfRestApiPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "restApiPassword");
          final int _cursorIndexOfPortalSupportPhone = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSupportPhone");
          final int _cursorIndexOfPortalNotification = CursorUtil.getColumnIndexOrThrow(_cursor, "portalNotification");
          final int _cursorIndexOfPortalLiveEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveEnabled");
          final int _cursorIndexOfPortalLiveUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalLiveUrl");
          final int _cursorIndexOfPortalBreakEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakEnabled");
          final int _cursorIndexOfPortalBreakUrl = CursorUtil.getColumnIndexOrThrow(_cursor, "portalBreakUrl");
          final int _cursorIndexOfPortalSpeedtestEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "portalSpeedtestEnabled");
          final int _cursorIndexOfMaintenanceEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEnabled");
          final int _cursorIndexOfMaintenancePolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenancePolicy");
          final int _cursorIndexOfMaintenanceStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceStartTime");
          final int _cursorIndexOfMaintenanceEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "maintenanceEndTime");
          final int _cursorIndexOfAutoupdateStartTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateStartTime");
          final int _cursorIndexOfAutoupdateEndTime = CursorUtil.getColumnIndexOrThrow(_cursor, "autoupdateEndTime");
          final int _cursorIndexOfUplinkBand = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkBand");
          final int _cursorIndexOfUplinkSsid = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkSsid");
          final int _cursorIndexOfUplinkKey = CursorUtil.getColumnIndexOrThrow(_cursor, "uplinkKey");
          final int _cursorIndexOfMeshBand = CursorUtil.getColumnIndexOrThrow(_cursor, "meshBand");
          final int _cursorIndexOfMeshId = CursorUtil.getColumnIndexOrThrow(_cursor, "meshId");
          final int _cursorIndexOfMeshKey = CursorUtil.getColumnIndexOrThrow(_cursor, "meshKey");
          final int _cursorIndexOfRebootHours = CursorUtil.getColumnIndexOrThrow(_cursor, "rebootHours");
          final int _cursorIndexOfVlanSsid2g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid2g");
          final int _cursorIndexOfVlanSsid5g = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsid5g");
          final int _cursorIndexOfVlanSsidIpSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "vlanSsidIpSuffix");
          final int _cursorIndexOfHotspotSecondaryPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolStart");
          final int _cursorIndexOfHotspotSecondaryPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPoolEnd");
          final int _cursorIndexOfHotspotSecondaryPolicy = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotSecondaryPolicy");
          final int _cursorIndexOfHotspotMacAuthEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthEnabled");
          final int _cursorIndexOfHotspotMacAuthSuffix = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthSuffix");
          final int _cursorIndexOfHotspotMacAuthPassword = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotMacAuthPassword");
          final int _cursorIndexOfHotspotWalledGarden = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotWalledGarden");
          final int _cursorIndexOfHotspotBrowserCookieEnabled = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieEnabled");
          final int _cursorIndexOfHotspotBrowserCookieDays = CursorUtil.getColumnIndexOrThrow(_cursor, "hotspotBrowserCookieDays");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfIsTemplate = CursorUtil.getColumnIndexOrThrow(_cursor, "isTemplate");
          final Device _result;
          if (_cursor.moveToFirst()) {
            final int _tmpId;
            _tmpId = _cursor.getInt(_cursorIndexOfId);
            final String _tmpMacAddress;
            if (_cursor.isNull(_cursorIndexOfMacAddress)) {
              _tmpMacAddress = null;
            } else {
              _tmpMacAddress = _cursor.getString(_cursorIndexOfMacAddress);
            }
            final String _tmpDeviceName;
            if (_cursor.isNull(_cursorIndexOfDeviceName)) {
              _tmpDeviceName = null;
            } else {
              _tmpDeviceName = _cursor.getString(_cursorIndexOfDeviceName);
            }
            final String _tmpDeviceType;
            if (_cursor.isNull(_cursorIndexOfDeviceType)) {
              _tmpDeviceType = null;
            } else {
              _tmpDeviceType = _cursor.getString(_cursorIndexOfDeviceType);
            }
            final String _tmpLanIp;
            if (_cursor.isNull(_cursorIndexOfLanIp)) {
              _tmpLanIp = null;
            } else {
              _tmpLanIp = _cursor.getString(_cursorIndexOfLanIp);
            }
            final String _tmpLanNetmask;
            if (_cursor.isNull(_cursorIndexOfLanNetmask)) {
              _tmpLanNetmask = null;
            } else {
              _tmpLanNetmask = _cursor.getString(_cursorIndexOfLanNetmask);
            }
            final String _tmpWifiSsid;
            if (_cursor.isNull(_cursorIndexOfWifiSsid)) {
              _tmpWifiSsid = null;
            } else {
              _tmpWifiSsid = _cursor.getString(_cursorIndexOfWifiSsid);
            }
            final String _tmpWifiKey;
            if (_cursor.isNull(_cursorIndexOfWifiKey)) {
              _tmpWifiKey = null;
            } else {
              _tmpWifiKey = _cursor.getString(_cursorIndexOfWifiKey);
            }
            final String _tmpWifiChannel;
            if (_cursor.isNull(_cursorIndexOfWifiChannel)) {
              _tmpWifiChannel = null;
            } else {
              _tmpWifiChannel = _cursor.getString(_cursorIndexOfWifiChannel);
            }
            final String _tmpWifi2gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi2gChannel)) {
              _tmpWifi2gChannel = null;
            } else {
              _tmpWifi2gChannel = _cursor.getString(_cursorIndexOfWifi2gChannel);
            }
            final String _tmpWifi2gMode;
            if (_cursor.isNull(_cursorIndexOfWifi2gMode)) {
              _tmpWifi2gMode = null;
            } else {
              _tmpWifi2gMode = _cursor.getString(_cursorIndexOfWifi2gMode);
            }
            final String _tmpWifi2gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi2gWidth)) {
              _tmpWifi2gWidth = null;
            } else {
              _tmpWifi2gWidth = _cursor.getString(_cursorIndexOfWifi2gWidth);
            }
            final String _tmpWifi5gChannel;
            if (_cursor.isNull(_cursorIndexOfWifi5gChannel)) {
              _tmpWifi5gChannel = null;
            } else {
              _tmpWifi5gChannel = _cursor.getString(_cursorIndexOfWifi5gChannel);
            }
            final String _tmpWifi5gMode;
            if (_cursor.isNull(_cursorIndexOfWifi5gMode)) {
              _tmpWifi5gMode = null;
            } else {
              _tmpWifi5gMode = _cursor.getString(_cursorIndexOfWifi5gMode);
            }
            final String _tmpWifi5gWidth;
            if (_cursor.isNull(_cursorIndexOfWifi5gWidth)) {
              _tmpWifi5gWidth = null;
            } else {
              _tmpWifi5gWidth = _cursor.getString(_cursorIndexOfWifi5gWidth);
            }
            final String _tmpWifi5gNameType;
            if (_cursor.isNull(_cursorIndexOfWifi5gNameType)) {
              _tmpWifi5gNameType = null;
            } else {
              _tmpWifi5gNameType = _cursor.getString(_cursorIndexOfWifi5gNameType);
            }
            final String _tmpWifi5gCustomSsid;
            if (_cursor.isNull(_cursorIndexOfWifi5gCustomSsid)) {
              _tmpWifi5gCustomSsid = null;
            } else {
              _tmpWifi5gCustomSsid = _cursor.getString(_cursorIndexOfWifi5gCustomSsid);
            }
            final boolean _tmpAppendIpToSsid;
            final int _tmp;
            _tmp = _cursor.getInt(_cursorIndexOfAppendIpToSsid);
            _tmpAppendIpToSsid = _tmp != 0;
            final String _tmpOtaWindowStart;
            if (_cursor.isNull(_cursorIndexOfOtaWindowStart)) {
              _tmpOtaWindowStart = null;
            } else {
              _tmpOtaWindowStart = _cursor.getString(_cursorIndexOfOtaWindowStart);
            }
            final String _tmpOtaWindowEnd;
            if (_cursor.isNull(_cursorIndexOfOtaWindowEnd)) {
              _tmpOtaWindowEnd = null;
            } else {
              _tmpOtaWindowEnd = _cursor.getString(_cursorIndexOfOtaWindowEnd);
            }
            final boolean _tmpVlanEnabled;
            final int _tmp_1;
            _tmp_1 = _cursor.getInt(_cursorIndexOfVlanEnabled);
            _tmpVlanEnabled = _tmp_1 != 0;
            final String _tmpVlanId;
            if (_cursor.isNull(_cursorIndexOfVlanId)) {
              _tmpVlanId = null;
            } else {
              _tmpVlanId = _cursor.getString(_cursorIndexOfVlanId);
            }
            final boolean _tmpAppendIpToVlanSsid;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfAppendIpToVlanSsid);
            _tmpAppendIpToVlanSsid = _tmp_2 != 0;
            final boolean _tmpDisableResetButton;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfDisableResetButton);
            _tmpDisableResetButton = _tmp_3 != 0;
            final String _tmpResetPressDuration;
            if (_cursor.isNull(_cursorIndexOfResetPressDuration)) {
              _tmpResetPressDuration = null;
            } else {
              _tmpResetPressDuration = _cursor.getString(_cursorIndexOfResetPressDuration);
            }
            final boolean _tmpDisableWpsButton;
            final int _tmp_4;
            _tmp_4 = _cursor.getInt(_cursorIndexOfDisableWpsButton);
            _tmpDisableWpsButton = _tmp_4 != 0;
            final boolean _tmpAutoRebootEnabled;
            final int _tmp_5;
            _tmp_5 = _cursor.getInt(_cursorIndexOfAutoRebootEnabled);
            _tmpAutoRebootEnabled = _tmp_5 != 0;
            final String _tmpRootPassword;
            if (_cursor.isNull(_cursorIndexOfRootPassword)) {
              _tmpRootPassword = null;
            } else {
              _tmpRootPassword = _cursor.getString(_cursorIndexOfRootPassword);
            }
            final String _tmpHotspotWanInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotWanInterface)) {
              _tmpHotspotWanInterface = null;
            } else {
              _tmpHotspotWanInterface = _cursor.getString(_cursorIndexOfHotspotWanInterface);
            }
            final String _tmpHotspotSubscriberInterface;
            if (_cursor.isNull(_cursorIndexOfHotspotSubscriberInterface)) {
              _tmpHotspotSubscriberInterface = null;
            } else {
              _tmpHotspotSubscriberInterface = _cursor.getString(_cursorIndexOfHotspotSubscriberInterface);
            }
            final String _tmpHotspotPrimaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryIp)) {
              _tmpHotspotPrimaryIp = null;
            } else {
              _tmpHotspotPrimaryIp = _cursor.getString(_cursorIndexOfHotspotPrimaryIp);
            }
            final String _tmpHotspotPrimaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolStart)) {
              _tmpHotspotPrimaryPoolStart = null;
            } else {
              _tmpHotspotPrimaryPoolStart = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolStart);
            }
            final String _tmpHotspotPrimaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPoolEnd)) {
              _tmpHotspotPrimaryPoolEnd = null;
            } else {
              _tmpHotspotPrimaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotPrimaryPoolEnd);
            }
            final String _tmpHotspotPrimaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotPrimaryPolicy)) {
              _tmpHotspotPrimaryPolicy = null;
            } else {
              _tmpHotspotPrimaryPolicy = _cursor.getString(_cursorIndexOfHotspotPrimaryPolicy);
            }
            final String _tmpHotspotDnsName;
            if (_cursor.isNull(_cursorIndexOfHotspotDnsName)) {
              _tmpHotspotDnsName = null;
            } else {
              _tmpHotspotDnsName = _cursor.getString(_cursorIndexOfHotspotDnsName);
            }
            final String _tmpHotspotDns1;
            if (_cursor.isNull(_cursorIndexOfHotspotDns1)) {
              _tmpHotspotDns1 = null;
            } else {
              _tmpHotspotDns1 = _cursor.getString(_cursorIndexOfHotspotDns1);
            }
            final String _tmpHotspotDns2;
            if (_cursor.isNull(_cursorIndexOfHotspotDns2)) {
              _tmpHotspotDns2 = null;
            } else {
              _tmpHotspotDns2 = _cursor.getString(_cursorIndexOfHotspotDns2);
            }
            final String _tmpHotspotBridgeAgeingTime;
            if (_cursor.isNull(_cursorIndexOfHotspotBridgeAgeingTime)) {
              _tmpHotspotBridgeAgeingTime = null;
            } else {
              _tmpHotspotBridgeAgeingTime = _cursor.getString(_cursorIndexOfHotspotBridgeAgeingTime);
            }
            final String _tmpHotspotCardPage;
            if (_cursor.isNull(_cursorIndexOfHotspotCardPage)) {
              _tmpHotspotCardPage = null;
            } else {
              _tmpHotspotCardPage = _cursor.getString(_cursorIndexOfHotspotCardPage);
            }
            final String _tmpHotspotRateLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotRateLimit)) {
              _tmpHotspotRateLimit = null;
            } else {
              _tmpHotspotRateLimit = _cursor.getString(_cursorIndexOfHotspotRateLimit);
            }
            final boolean _tmpHotspotMacCookie;
            final int _tmp_6;
            _tmp_6 = _cursor.getInt(_cursorIndexOfHotspotMacCookie);
            _tmpHotspotMacCookie = _tmp_6 != 0;
            final String _tmpHotspotAvailableSpeeds;
            if (_cursor.isNull(_cursorIndexOfHotspotAvailableSpeeds)) {
              _tmpHotspotAvailableSpeeds = null;
            } else {
              _tmpHotspotAvailableSpeeds = _cursor.getString(_cursorIndexOfHotspotAvailableSpeeds);
            }
            final boolean _tmpHotspotSecondaryEnabled;
            final int _tmp_7;
            _tmp_7 = _cursor.getInt(_cursorIndexOfHotspotSecondaryEnabled);
            _tmpHotspotSecondaryEnabled = _tmp_7 != 0;
            final String _tmpHotspotSecondarySsid;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondarySsid)) {
              _tmpHotspotSecondarySsid = null;
            } else {
              _tmpHotspotSecondarySsid = _cursor.getString(_cursorIndexOfHotspotSecondarySsid);
            }
            final String _tmpHotspotSecondaryIp;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryIp)) {
              _tmpHotspotSecondaryIp = null;
            } else {
              _tmpHotspotSecondaryIp = _cursor.getString(_cursorIndexOfHotspotSecondaryIp);
            }
            final boolean _tmpHotspotTrialEnabled;
            final int _tmp_8;
            _tmp_8 = _cursor.getInt(_cursorIndexOfHotspotTrialEnabled);
            _tmpHotspotTrialEnabled = _tmp_8 != 0;
            final String _tmpHotspotTrialDuration;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialDuration)) {
              _tmpHotspotTrialDuration = null;
            } else {
              _tmpHotspotTrialDuration = _cursor.getString(_cursorIndexOfHotspotTrialDuration);
            }
            final String _tmpHotspotTrialUptimeLimit;
            if (_cursor.isNull(_cursorIndexOfHotspotTrialUptimeLimit)) {
              _tmpHotspotTrialUptimeLimit = null;
            } else {
              _tmpHotspotTrialUptimeLimit = _cursor.getString(_cursorIndexOfHotspotTrialUptimeLimit);
            }
            final String _tmpRadiusServer;
            if (_cursor.isNull(_cursorIndexOfRadiusServer)) {
              _tmpRadiusServer = null;
            } else {
              _tmpRadiusServer = _cursor.getString(_cursorIndexOfRadiusServer);
            }
            final String _tmpRadiusServerBackup;
            if (_cursor.isNull(_cursorIndexOfRadiusServerBackup)) {
              _tmpRadiusServerBackup = null;
            } else {
              _tmpRadiusServerBackup = _cursor.getString(_cursorIndexOfRadiusServerBackup);
            }
            final String _tmpRadiusSecret;
            if (_cursor.isNull(_cursorIndexOfRadiusSecret)) {
              _tmpRadiusSecret = null;
            } else {
              _tmpRadiusSecret = _cursor.getString(_cursorIndexOfRadiusSecret);
            }
            final String _tmpRadiusAuthPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAuthPort)) {
              _tmpRadiusAuthPort = null;
            } else {
              _tmpRadiusAuthPort = _cursor.getString(_cursorIndexOfRadiusAuthPort);
            }
            final String _tmpRadiusAcctPort;
            if (_cursor.isNull(_cursorIndexOfRadiusAcctPort)) {
              _tmpRadiusAcctPort = null;
            } else {
              _tmpRadiusAcctPort = _cursor.getString(_cursorIndexOfRadiusAcctPort);
            }
            final String _tmpRadiusNasIp;
            if (_cursor.isNull(_cursorIndexOfRadiusNasIp)) {
              _tmpRadiusNasIp = null;
            } else {
              _tmpRadiusNasIp = _cursor.getString(_cursorIndexOfRadiusNasIp);
            }
            final String _tmpRadiusNasId;
            if (_cursor.isNull(_cursorIndexOfRadiusNasId)) {
              _tmpRadiusNasId = null;
            } else {
              _tmpRadiusNasId = _cursor.getString(_cursorIndexOfRadiusNasId);
            }
            final String _tmpRadiusInterimUpdate;
            if (_cursor.isNull(_cursorIndexOfRadiusInterimUpdate)) {
              _tmpRadiusInterimUpdate = null;
            } else {
              _tmpRadiusInterimUpdate = _cursor.getString(_cursorIndexOfRadiusInterimUpdate);
            }
            final boolean _tmpRadiusCoaEnabled;
            final int _tmp_9;
            _tmp_9 = _cursor.getInt(_cursorIndexOfRadiusCoaEnabled);
            _tmpRadiusCoaEnabled = _tmp_9 != 0;
            final String _tmpRadiusCoaPort;
            if (_cursor.isNull(_cursorIndexOfRadiusCoaPort)) {
              _tmpRadiusCoaPort = null;
            } else {
              _tmpRadiusCoaPort = _cursor.getString(_cursorIndexOfRadiusCoaPort);
            }
            final boolean _tmpRestApiEnabled;
            final int _tmp_10;
            _tmp_10 = _cursor.getInt(_cursorIndexOfRestApiEnabled);
            _tmpRestApiEnabled = _tmp_10 != 0;
            final String _tmpRestApiProto;
            if (_cursor.isNull(_cursorIndexOfRestApiProto)) {
              _tmpRestApiProto = null;
            } else {
              _tmpRestApiProto = _cursor.getString(_cursorIndexOfRestApiProto);
            }
            final String _tmpRestApiUsername;
            if (_cursor.isNull(_cursorIndexOfRestApiUsername)) {
              _tmpRestApiUsername = null;
            } else {
              _tmpRestApiUsername = _cursor.getString(_cursorIndexOfRestApiUsername);
            }
            final String _tmpRestApiPassword;
            if (_cursor.isNull(_cursorIndexOfRestApiPassword)) {
              _tmpRestApiPassword = null;
            } else {
              _tmpRestApiPassword = _cursor.getString(_cursorIndexOfRestApiPassword);
            }
            final String _tmpPortalSupportPhone;
            if (_cursor.isNull(_cursorIndexOfPortalSupportPhone)) {
              _tmpPortalSupportPhone = null;
            } else {
              _tmpPortalSupportPhone = _cursor.getString(_cursorIndexOfPortalSupportPhone);
            }
            final String _tmpPortalNotification;
            if (_cursor.isNull(_cursorIndexOfPortalNotification)) {
              _tmpPortalNotification = null;
            } else {
              _tmpPortalNotification = _cursor.getString(_cursorIndexOfPortalNotification);
            }
            final boolean _tmpPortalLiveEnabled;
            final int _tmp_11;
            _tmp_11 = _cursor.getInt(_cursorIndexOfPortalLiveEnabled);
            _tmpPortalLiveEnabled = _tmp_11 != 0;
            final String _tmpPortalLiveUrl;
            if (_cursor.isNull(_cursorIndexOfPortalLiveUrl)) {
              _tmpPortalLiveUrl = null;
            } else {
              _tmpPortalLiveUrl = _cursor.getString(_cursorIndexOfPortalLiveUrl);
            }
            final boolean _tmpPortalBreakEnabled;
            final int _tmp_12;
            _tmp_12 = _cursor.getInt(_cursorIndexOfPortalBreakEnabled);
            _tmpPortalBreakEnabled = _tmp_12 != 0;
            final String _tmpPortalBreakUrl;
            if (_cursor.isNull(_cursorIndexOfPortalBreakUrl)) {
              _tmpPortalBreakUrl = null;
            } else {
              _tmpPortalBreakUrl = _cursor.getString(_cursorIndexOfPortalBreakUrl);
            }
            final boolean _tmpPortalSpeedtestEnabled;
            final int _tmp_13;
            _tmp_13 = _cursor.getInt(_cursorIndexOfPortalSpeedtestEnabled);
            _tmpPortalSpeedtestEnabled = _tmp_13 != 0;
            final boolean _tmpMaintenanceEnabled;
            final int _tmp_14;
            _tmp_14 = _cursor.getInt(_cursorIndexOfMaintenanceEnabled);
            _tmpMaintenanceEnabled = _tmp_14 != 0;
            final String _tmpMaintenancePolicy;
            if (_cursor.isNull(_cursorIndexOfMaintenancePolicy)) {
              _tmpMaintenancePolicy = null;
            } else {
              _tmpMaintenancePolicy = _cursor.getString(_cursorIndexOfMaintenancePolicy);
            }
            final String _tmpMaintenanceStartTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceStartTime)) {
              _tmpMaintenanceStartTime = null;
            } else {
              _tmpMaintenanceStartTime = _cursor.getString(_cursorIndexOfMaintenanceStartTime);
            }
            final String _tmpMaintenanceEndTime;
            if (_cursor.isNull(_cursorIndexOfMaintenanceEndTime)) {
              _tmpMaintenanceEndTime = null;
            } else {
              _tmpMaintenanceEndTime = _cursor.getString(_cursorIndexOfMaintenanceEndTime);
            }
            final String _tmpAutoupdateStartTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateStartTime)) {
              _tmpAutoupdateStartTime = null;
            } else {
              _tmpAutoupdateStartTime = _cursor.getString(_cursorIndexOfAutoupdateStartTime);
            }
            final String _tmpAutoupdateEndTime;
            if (_cursor.isNull(_cursorIndexOfAutoupdateEndTime)) {
              _tmpAutoupdateEndTime = null;
            } else {
              _tmpAutoupdateEndTime = _cursor.getString(_cursorIndexOfAutoupdateEndTime);
            }
            final String _tmpUplinkBand;
            if (_cursor.isNull(_cursorIndexOfUplinkBand)) {
              _tmpUplinkBand = null;
            } else {
              _tmpUplinkBand = _cursor.getString(_cursorIndexOfUplinkBand);
            }
            final String _tmpUplinkSsid;
            if (_cursor.isNull(_cursorIndexOfUplinkSsid)) {
              _tmpUplinkSsid = null;
            } else {
              _tmpUplinkSsid = _cursor.getString(_cursorIndexOfUplinkSsid);
            }
            final String _tmpUplinkKey;
            if (_cursor.isNull(_cursorIndexOfUplinkKey)) {
              _tmpUplinkKey = null;
            } else {
              _tmpUplinkKey = _cursor.getString(_cursorIndexOfUplinkKey);
            }
            final String _tmpMeshBand;
            if (_cursor.isNull(_cursorIndexOfMeshBand)) {
              _tmpMeshBand = null;
            } else {
              _tmpMeshBand = _cursor.getString(_cursorIndexOfMeshBand);
            }
            final String _tmpMeshId;
            if (_cursor.isNull(_cursorIndexOfMeshId)) {
              _tmpMeshId = null;
            } else {
              _tmpMeshId = _cursor.getString(_cursorIndexOfMeshId);
            }
            final String _tmpMeshKey;
            if (_cursor.isNull(_cursorIndexOfMeshKey)) {
              _tmpMeshKey = null;
            } else {
              _tmpMeshKey = _cursor.getString(_cursorIndexOfMeshKey);
            }
            final String _tmpRebootHours;
            if (_cursor.isNull(_cursorIndexOfRebootHours)) {
              _tmpRebootHours = null;
            } else {
              _tmpRebootHours = _cursor.getString(_cursorIndexOfRebootHours);
            }
            final String _tmpVlanSsid2g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid2g)) {
              _tmpVlanSsid2g = null;
            } else {
              _tmpVlanSsid2g = _cursor.getString(_cursorIndexOfVlanSsid2g);
            }
            final String _tmpVlanSsid5g;
            if (_cursor.isNull(_cursorIndexOfVlanSsid5g)) {
              _tmpVlanSsid5g = null;
            } else {
              _tmpVlanSsid5g = _cursor.getString(_cursorIndexOfVlanSsid5g);
            }
            final boolean _tmpVlanSsidIpSuffix;
            final int _tmp_15;
            _tmp_15 = _cursor.getInt(_cursorIndexOfVlanSsidIpSuffix);
            _tmpVlanSsidIpSuffix = _tmp_15 != 0;
            final String _tmpHotspotSecondaryPoolStart;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolStart)) {
              _tmpHotspotSecondaryPoolStart = null;
            } else {
              _tmpHotspotSecondaryPoolStart = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolStart);
            }
            final String _tmpHotspotSecondaryPoolEnd;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPoolEnd)) {
              _tmpHotspotSecondaryPoolEnd = null;
            } else {
              _tmpHotspotSecondaryPoolEnd = _cursor.getString(_cursorIndexOfHotspotSecondaryPoolEnd);
            }
            final String _tmpHotspotSecondaryPolicy;
            if (_cursor.isNull(_cursorIndexOfHotspotSecondaryPolicy)) {
              _tmpHotspotSecondaryPolicy = null;
            } else {
              _tmpHotspotSecondaryPolicy = _cursor.getString(_cursorIndexOfHotspotSecondaryPolicy);
            }
            final boolean _tmpHotspotMacAuthEnabled;
            final int _tmp_16;
            _tmp_16 = _cursor.getInt(_cursorIndexOfHotspotMacAuthEnabled);
            _tmpHotspotMacAuthEnabled = _tmp_16 != 0;
            final String _tmpHotspotMacAuthSuffix;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthSuffix)) {
              _tmpHotspotMacAuthSuffix = null;
            } else {
              _tmpHotspotMacAuthSuffix = _cursor.getString(_cursorIndexOfHotspotMacAuthSuffix);
            }
            final String _tmpHotspotMacAuthPassword;
            if (_cursor.isNull(_cursorIndexOfHotspotMacAuthPassword)) {
              _tmpHotspotMacAuthPassword = null;
            } else {
              _tmpHotspotMacAuthPassword = _cursor.getString(_cursorIndexOfHotspotMacAuthPassword);
            }
            final String _tmpHotspotWalledGarden;
            if (_cursor.isNull(_cursorIndexOfHotspotWalledGarden)) {
              _tmpHotspotWalledGarden = null;
            } else {
              _tmpHotspotWalledGarden = _cursor.getString(_cursorIndexOfHotspotWalledGarden);
            }
            final boolean _tmpHotspotBrowserCookieEnabled;
            final int _tmp_17;
            _tmp_17 = _cursor.getInt(_cursorIndexOfHotspotBrowserCookieEnabled);
            _tmpHotspotBrowserCookieEnabled = _tmp_17 != 0;
            final String _tmpHotspotBrowserCookieDays;
            if (_cursor.isNull(_cursorIndexOfHotspotBrowserCookieDays)) {
              _tmpHotspotBrowserCookieDays = null;
            } else {
              _tmpHotspotBrowserCookieDays = _cursor.getString(_cursorIndexOfHotspotBrowserCookieDays);
            }
            final long _tmpTimestamp;
            _tmpTimestamp = _cursor.getLong(_cursorIndexOfTimestamp);
            final boolean _tmpIsTemplate;
            final int _tmp_18;
            _tmp_18 = _cursor.getInt(_cursorIndexOfIsTemplate);
            _tmpIsTemplate = _tmp_18 != 0;
            _result = new Device(_tmpId,_tmpMacAddress,_tmpDeviceName,_tmpDeviceType,_tmpLanIp,_tmpLanNetmask,_tmpWifiSsid,_tmpWifiKey,_tmpWifiChannel,_tmpWifi2gChannel,_tmpWifi2gMode,_tmpWifi2gWidth,_tmpWifi5gChannel,_tmpWifi5gMode,_tmpWifi5gWidth,_tmpWifi5gNameType,_tmpWifi5gCustomSsid,_tmpAppendIpToSsid,_tmpOtaWindowStart,_tmpOtaWindowEnd,_tmpVlanEnabled,_tmpVlanId,_tmpAppendIpToVlanSsid,_tmpDisableResetButton,_tmpResetPressDuration,_tmpDisableWpsButton,_tmpAutoRebootEnabled,_tmpRootPassword,_tmpHotspotWanInterface,_tmpHotspotSubscriberInterface,_tmpHotspotPrimaryIp,_tmpHotspotPrimaryPoolStart,_tmpHotspotPrimaryPoolEnd,_tmpHotspotPrimaryPolicy,_tmpHotspotDnsName,_tmpHotspotDns1,_tmpHotspotDns2,_tmpHotspotBridgeAgeingTime,_tmpHotspotCardPage,_tmpHotspotRateLimit,_tmpHotspotMacCookie,_tmpHotspotAvailableSpeeds,_tmpHotspotSecondaryEnabled,_tmpHotspotSecondarySsid,_tmpHotspotSecondaryIp,_tmpHotspotTrialEnabled,_tmpHotspotTrialDuration,_tmpHotspotTrialUptimeLimit,_tmpRadiusServer,_tmpRadiusServerBackup,_tmpRadiusSecret,_tmpRadiusAuthPort,_tmpRadiusAcctPort,_tmpRadiusNasIp,_tmpRadiusNasId,_tmpRadiusInterimUpdate,_tmpRadiusCoaEnabled,_tmpRadiusCoaPort,_tmpRestApiEnabled,_tmpRestApiProto,_tmpRestApiUsername,_tmpRestApiPassword,_tmpPortalSupportPhone,_tmpPortalNotification,_tmpPortalLiveEnabled,_tmpPortalLiveUrl,_tmpPortalBreakEnabled,_tmpPortalBreakUrl,_tmpPortalSpeedtestEnabled,_tmpMaintenanceEnabled,_tmpMaintenancePolicy,_tmpMaintenanceStartTime,_tmpMaintenanceEndTime,_tmpAutoupdateStartTime,_tmpAutoupdateEndTime,_tmpUplinkBand,_tmpUplinkSsid,_tmpUplinkKey,_tmpMeshBand,_tmpMeshId,_tmpMeshKey,_tmpRebootHours,_tmpVlanSsid2g,_tmpVlanSsid5g,_tmpVlanSsidIpSuffix,_tmpHotspotSecondaryPoolStart,_tmpHotspotSecondaryPoolEnd,_tmpHotspotSecondaryPolicy,_tmpHotspotMacAuthEnabled,_tmpHotspotMacAuthSuffix,_tmpHotspotMacAuthPassword,_tmpHotspotWalledGarden,_tmpHotspotBrowserCookieEnabled,_tmpHotspotBrowserCookieDays,_tmpTimestamp,_tmpIsTemplate);
          } else {
            _result = null;
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object getAllSubnetPools(final Continuation<? super List<SubnetPool>> $completion) {
    final String _sql = "SELECT * FROM subnet_pools";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<SubnetPool>>() {
      @Override
      @NonNull
      public List<SubnetPool> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfDeviceMac = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceMac");
          final int _cursorIndexOfPoolNetwork = CursorUtil.getColumnIndexOrThrow(_cursor, "poolNetwork");
          final int _cursorIndexOfPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "poolStart");
          final int _cursorIndexOfPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "poolEnd");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final List<SubnetPool> _result = new ArrayList<SubnetPool>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final SubnetPool _item;
            final int _tmpId;
            _tmpId = _cursor.getInt(_cursorIndexOfId);
            final String _tmpDeviceMac;
            if (_cursor.isNull(_cursorIndexOfDeviceMac)) {
              _tmpDeviceMac = null;
            } else {
              _tmpDeviceMac = _cursor.getString(_cursorIndexOfDeviceMac);
            }
            final String _tmpPoolNetwork;
            if (_cursor.isNull(_cursorIndexOfPoolNetwork)) {
              _tmpPoolNetwork = null;
            } else {
              _tmpPoolNetwork = _cursor.getString(_cursorIndexOfPoolNetwork);
            }
            final String _tmpPoolStart;
            if (_cursor.isNull(_cursorIndexOfPoolStart)) {
              _tmpPoolStart = null;
            } else {
              _tmpPoolStart = _cursor.getString(_cursorIndexOfPoolStart);
            }
            final String _tmpPoolEnd;
            if (_cursor.isNull(_cursorIndexOfPoolEnd)) {
              _tmpPoolEnd = null;
            } else {
              _tmpPoolEnd = _cursor.getString(_cursorIndexOfPoolEnd);
            }
            final long _tmpTimestamp;
            _tmpTimestamp = _cursor.getLong(_cursorIndexOfTimestamp);
            _item = new SubnetPool(_tmpId,_tmpDeviceMac,_tmpPoolNetwork,_tmpPoolStart,_tmpPoolEnd,_tmpTimestamp);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object getPoolByNetwork(final String network,
      final Continuation<? super SubnetPool> $completion) {
    final String _sql = "SELECT * FROM subnet_pools WHERE poolNetwork = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    if (network == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindString(_argIndex, network);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<SubnetPool>() {
      @Override
      @Nullable
      public SubnetPool call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfDeviceMac = CursorUtil.getColumnIndexOrThrow(_cursor, "deviceMac");
          final int _cursorIndexOfPoolNetwork = CursorUtil.getColumnIndexOrThrow(_cursor, "poolNetwork");
          final int _cursorIndexOfPoolStart = CursorUtil.getColumnIndexOrThrow(_cursor, "poolStart");
          final int _cursorIndexOfPoolEnd = CursorUtil.getColumnIndexOrThrow(_cursor, "poolEnd");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final SubnetPool _result;
          if (_cursor.moveToFirst()) {
            final int _tmpId;
            _tmpId = _cursor.getInt(_cursorIndexOfId);
            final String _tmpDeviceMac;
            if (_cursor.isNull(_cursorIndexOfDeviceMac)) {
              _tmpDeviceMac = null;
            } else {
              _tmpDeviceMac = _cursor.getString(_cursorIndexOfDeviceMac);
            }
            final String _tmpPoolNetwork;
            if (_cursor.isNull(_cursorIndexOfPoolNetwork)) {
              _tmpPoolNetwork = null;
            } else {
              _tmpPoolNetwork = _cursor.getString(_cursorIndexOfPoolNetwork);
            }
            final String _tmpPoolStart;
            if (_cursor.isNull(_cursorIndexOfPoolStart)) {
              _tmpPoolStart = null;
            } else {
              _tmpPoolStart = _cursor.getString(_cursorIndexOfPoolStart);
            }
            final String _tmpPoolEnd;
            if (_cursor.isNull(_cursorIndexOfPoolEnd)) {
              _tmpPoolEnd = null;
            } else {
              _tmpPoolEnd = _cursor.getString(_cursorIndexOfPoolEnd);
            }
            final long _tmpTimestamp;
            _tmpTimestamp = _cursor.getLong(_cursorIndexOfTimestamp);
            _result = new SubnetPool(_tmpId,_tmpDeviceMac,_tmpPoolNetwork,_tmpPoolStart,_tmpPoolEnd,_tmpTimestamp);
          } else {
            _result = null;
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
