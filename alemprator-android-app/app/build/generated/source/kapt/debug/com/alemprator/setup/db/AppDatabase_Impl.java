package com.alemprator.setup.db;

import androidx.annotation.NonNull;
import androidx.room.DatabaseConfiguration;
import androidx.room.InvalidationTracker;
import androidx.room.RoomDatabase;
import androidx.room.RoomOpenHelper;
import androidx.room.migration.AutoMigrationSpec;
import androidx.room.migration.Migration;
import androidx.room.util.DBUtil;
import androidx.room.util.TableInfo;
import androidx.sqlite.db.SupportSQLiteDatabase;
import androidx.sqlite.db.SupportSQLiteOpenHelper;
import java.lang.Class;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.annotation.processing.Generated;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class AppDatabase_Impl extends AppDatabase {
  private volatile DeviceDao _deviceDao;

  @Override
  @NonNull
  protected SupportSQLiteOpenHelper createOpenHelper(@NonNull final DatabaseConfiguration config) {
    final SupportSQLiteOpenHelper.Callback _openCallback = new RoomOpenHelper(config, new RoomOpenHelper.Delegate(11) {
      @Override
      public void createAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("CREATE TABLE IF NOT EXISTS `devices` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `macAddress` TEXT NOT NULL, `deviceName` TEXT NOT NULL, `deviceType` TEXT NOT NULL, `lanIp` TEXT NOT NULL, `wifiSsid` TEXT, `wifiKey` TEXT, `wifiChannel` TEXT, `wifi2gChannel` TEXT NOT NULL, `wifi2gMode` TEXT NOT NULL, `wifi2gWidth` TEXT NOT NULL, `wifi5gChannel` TEXT NOT NULL, `wifi5gMode` TEXT NOT NULL, `wifi5gWidth` TEXT NOT NULL, `wifi5gNameType` TEXT NOT NULL, `wifi5gCustomSsid` TEXT, `appendIpToSsid` INTEGER NOT NULL, `noPassword` INTEGER NOT NULL, `vlanEnabled` INTEGER NOT NULL, `vlanId` TEXT, `appendIpToVlanSsid` INTEGER NOT NULL, `disableResetButton` INTEGER NOT NULL, `resetPressDuration` TEXT NOT NULL, `disableWpsButton` INTEGER NOT NULL, `autoRebootEnabled` INTEGER NOT NULL, `rootPassword` TEXT, `isolateClients` INTEGER NOT NULL, `hideSsid` INTEGER NOT NULL, `disableDhcp` INTEGER NOT NULL, `hotspotDnsName` TEXT NOT NULL, `hotspotCardPage` TEXT NOT NULL, `hotspotRateLimit` TEXT NOT NULL, `hotspotMacCookie` INTEGER NOT NULL, `hotspotSecondaryEnabled` INTEGER NOT NULL, `hotspotSecondarySsid` TEXT, `hotspotSecondaryIp` TEXT, `hotspotTrialEnabled` INTEGER NOT NULL, `hotspotTrialDuration` TEXT NOT NULL, `hotspotTrialUptimeLimit` TEXT NOT NULL, `radiusServer` TEXT NOT NULL, `radiusServerBackup` TEXT, `radiusSecret` TEXT, `radiusAuthPort` TEXT NOT NULL, `radiusAcctPort` TEXT NOT NULL, `radiusNasIp` TEXT NOT NULL, `radiusNasId` TEXT NOT NULL, `radiusInterimUpdate` TEXT NOT NULL, `radiusCoaEnabled` INTEGER NOT NULL, `radiusCoaPort` TEXT NOT NULL, `restApiEnabled` INTEGER NOT NULL, `restApiProto` TEXT NOT NULL, `restApiUsername` TEXT NOT NULL, `restApiPassword` TEXT, `portalSupportPhone` TEXT, `portalNotification` TEXT NOT NULL, `portalLiveEnabled` INTEGER NOT NULL, `portalLiveUrl` TEXT, `portalBreakEnabled` INTEGER NOT NULL, `portalBreakUrl` TEXT, `portalSpeedtestEnabled` INTEGER NOT NULL, `maintenanceEnabled` INTEGER NOT NULL, `maintenancePolicy` TEXT NOT NULL, `maintenanceStartTime` TEXT NOT NULL, `maintenanceEndTime` TEXT NOT NULL, `autoupdateStartTime` TEXT NOT NULL, `autoupdateEndTime` TEXT NOT NULL, `uplinkBand` TEXT NOT NULL, `uplinkSsid` TEXT, `uplinkKey` TEXT, `meshBand` TEXT NOT NULL, `meshId` TEXT, `meshKey` TEXT, `rebootHours` TEXT NOT NULL, `vlanSsid2g` TEXT, `vlanSsid5g` TEXT, `vlanSsidIpSuffix` INTEGER NOT NULL, `hotspotSecondaryPoolStart` TEXT, `hotspotSecondaryPoolEnd` TEXT, `hotspotSecondaryPolicy` TEXT NOT NULL, `hotspotMacAuthEnabled` INTEGER NOT NULL, `hotspotMacAuthSuffix` TEXT, `hotspotMacAuthPassword` TEXT, `hotspotWalledGarden` TEXT, `hotspotBrowserCookieEnabled` INTEGER NOT NULL, `hotspotBrowserCookieDays` TEXT NOT NULL, `timestamp` INTEGER NOT NULL)");
        db.execSQL("CREATE TABLE IF NOT EXISTS `subnet_pools` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `deviceMac` TEXT NOT NULL, `poolNetwork` TEXT NOT NULL, `poolStart` TEXT NOT NULL, `poolEnd` TEXT NOT NULL, `timestamp` INTEGER NOT NULL)");
        db.execSQL("CREATE TABLE IF NOT EXISTS room_master_table (id INTEGER PRIMARY KEY,identity_hash TEXT)");
        db.execSQL("INSERT OR REPLACE INTO room_master_table (id,identity_hash) VALUES(42, '135cc93326a68ded21e0e29ddf46dd21')");
      }

      @Override
      public void dropAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("DROP TABLE IF EXISTS `devices`");
        db.execSQL("DROP TABLE IF EXISTS `subnet_pools`");
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onDestructiveMigration(db);
          }
        }
      }

      @Override
      public void onCreate(@NonNull final SupportSQLiteDatabase db) {
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onCreate(db);
          }
        }
      }

      @Override
      public void onOpen(@NonNull final SupportSQLiteDatabase db) {
        mDatabase = db;
        internalInitInvalidationTracker(db);
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onOpen(db);
          }
        }
      }

      @Override
      public void onPreMigrate(@NonNull final SupportSQLiteDatabase db) {
        DBUtil.dropFtsSyncTriggers(db);
      }

      @Override
      public void onPostMigrate(@NonNull final SupportSQLiteDatabase db) {
      }

      @Override
      @NonNull
      public RoomOpenHelper.ValidationResult onValidateSchema(
          @NonNull final SupportSQLiteDatabase db) {
        final HashMap<String, TableInfo.Column> _columnsDevices = new HashMap<String, TableInfo.Column>(86);
        _columnsDevices.put("id", new TableInfo.Column("id", "INTEGER", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("macAddress", new TableInfo.Column("macAddress", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("deviceName", new TableInfo.Column("deviceName", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("deviceType", new TableInfo.Column("deviceType", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("lanIp", new TableInfo.Column("lanIp", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifiSsid", new TableInfo.Column("wifiSsid", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifiKey", new TableInfo.Column("wifiKey", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifiChannel", new TableInfo.Column("wifiChannel", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi2gChannel", new TableInfo.Column("wifi2gChannel", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi2gMode", new TableInfo.Column("wifi2gMode", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi2gWidth", new TableInfo.Column("wifi2gWidth", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi5gChannel", new TableInfo.Column("wifi5gChannel", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi5gMode", new TableInfo.Column("wifi5gMode", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi5gWidth", new TableInfo.Column("wifi5gWidth", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi5gNameType", new TableInfo.Column("wifi5gNameType", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("wifi5gCustomSsid", new TableInfo.Column("wifi5gCustomSsid", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("appendIpToSsid", new TableInfo.Column("appendIpToSsid", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("noPassword", new TableInfo.Column("noPassword", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("vlanEnabled", new TableInfo.Column("vlanEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("vlanId", new TableInfo.Column("vlanId", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("appendIpToVlanSsid", new TableInfo.Column("appendIpToVlanSsid", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("disableResetButton", new TableInfo.Column("disableResetButton", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("resetPressDuration", new TableInfo.Column("resetPressDuration", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("disableWpsButton", new TableInfo.Column("disableWpsButton", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("autoRebootEnabled", new TableInfo.Column("autoRebootEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("rootPassword", new TableInfo.Column("rootPassword", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("isolateClients", new TableInfo.Column("isolateClients", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hideSsid", new TableInfo.Column("hideSsid", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("disableDhcp", new TableInfo.Column("disableDhcp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotDnsName", new TableInfo.Column("hotspotDnsName", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotCardPage", new TableInfo.Column("hotspotCardPage", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotRateLimit", new TableInfo.Column("hotspotRateLimit", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotMacCookie", new TableInfo.Column("hotspotMacCookie", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotSecondaryEnabled", new TableInfo.Column("hotspotSecondaryEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotSecondarySsid", new TableInfo.Column("hotspotSecondarySsid", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotSecondaryIp", new TableInfo.Column("hotspotSecondaryIp", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotTrialEnabled", new TableInfo.Column("hotspotTrialEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotTrialDuration", new TableInfo.Column("hotspotTrialDuration", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotTrialUptimeLimit", new TableInfo.Column("hotspotTrialUptimeLimit", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusServer", new TableInfo.Column("radiusServer", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusServerBackup", new TableInfo.Column("radiusServerBackup", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusSecret", new TableInfo.Column("radiusSecret", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusAuthPort", new TableInfo.Column("radiusAuthPort", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusAcctPort", new TableInfo.Column("radiusAcctPort", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusNasIp", new TableInfo.Column("radiusNasIp", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusNasId", new TableInfo.Column("radiusNasId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusInterimUpdate", new TableInfo.Column("radiusInterimUpdate", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusCoaEnabled", new TableInfo.Column("radiusCoaEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("radiusCoaPort", new TableInfo.Column("radiusCoaPort", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("restApiEnabled", new TableInfo.Column("restApiEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("restApiProto", new TableInfo.Column("restApiProto", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("restApiUsername", new TableInfo.Column("restApiUsername", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("restApiPassword", new TableInfo.Column("restApiPassword", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("portalSupportPhone", new TableInfo.Column("portalSupportPhone", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("portalNotification", new TableInfo.Column("portalNotification", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("portalLiveEnabled", new TableInfo.Column("portalLiveEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("portalLiveUrl", new TableInfo.Column("portalLiveUrl", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("portalBreakEnabled", new TableInfo.Column("portalBreakEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("portalBreakUrl", new TableInfo.Column("portalBreakUrl", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("portalSpeedtestEnabled", new TableInfo.Column("portalSpeedtestEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("maintenanceEnabled", new TableInfo.Column("maintenanceEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("maintenancePolicy", new TableInfo.Column("maintenancePolicy", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("maintenanceStartTime", new TableInfo.Column("maintenanceStartTime", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("maintenanceEndTime", new TableInfo.Column("maintenanceEndTime", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("autoupdateStartTime", new TableInfo.Column("autoupdateStartTime", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("autoupdateEndTime", new TableInfo.Column("autoupdateEndTime", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("uplinkBand", new TableInfo.Column("uplinkBand", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("uplinkSsid", new TableInfo.Column("uplinkSsid", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("uplinkKey", new TableInfo.Column("uplinkKey", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("meshBand", new TableInfo.Column("meshBand", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("meshId", new TableInfo.Column("meshId", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("meshKey", new TableInfo.Column("meshKey", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("rebootHours", new TableInfo.Column("rebootHours", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("vlanSsid2g", new TableInfo.Column("vlanSsid2g", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("vlanSsid5g", new TableInfo.Column("vlanSsid5g", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("vlanSsidIpSuffix", new TableInfo.Column("vlanSsidIpSuffix", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotSecondaryPoolStart", new TableInfo.Column("hotspotSecondaryPoolStart", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotSecondaryPoolEnd", new TableInfo.Column("hotspotSecondaryPoolEnd", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotSecondaryPolicy", new TableInfo.Column("hotspotSecondaryPolicy", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotMacAuthEnabled", new TableInfo.Column("hotspotMacAuthEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotMacAuthSuffix", new TableInfo.Column("hotspotMacAuthSuffix", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotMacAuthPassword", new TableInfo.Column("hotspotMacAuthPassword", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotWalledGarden", new TableInfo.Column("hotspotWalledGarden", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotBrowserCookieEnabled", new TableInfo.Column("hotspotBrowserCookieEnabled", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("hotspotBrowserCookieDays", new TableInfo.Column("hotspotBrowserCookieDays", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDevices.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysDevices = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesDevices = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoDevices = new TableInfo("devices", _columnsDevices, _foreignKeysDevices, _indicesDevices);
        final TableInfo _existingDevices = TableInfo.read(db, "devices");
        if (!_infoDevices.equals(_existingDevices)) {
          return new RoomOpenHelper.ValidationResult(false, "devices(com.alemprator.setup.db.Device).\n"
                  + " Expected:\n" + _infoDevices + "\n"
                  + " Found:\n" + _existingDevices);
        }
        final HashMap<String, TableInfo.Column> _columnsSubnetPools = new HashMap<String, TableInfo.Column>(6);
        _columnsSubnetPools.put("id", new TableInfo.Column("id", "INTEGER", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSubnetPools.put("deviceMac", new TableInfo.Column("deviceMac", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSubnetPools.put("poolNetwork", new TableInfo.Column("poolNetwork", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSubnetPools.put("poolStart", new TableInfo.Column("poolStart", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSubnetPools.put("poolEnd", new TableInfo.Column("poolEnd", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSubnetPools.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysSubnetPools = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesSubnetPools = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoSubnetPools = new TableInfo("subnet_pools", _columnsSubnetPools, _foreignKeysSubnetPools, _indicesSubnetPools);
        final TableInfo _existingSubnetPools = TableInfo.read(db, "subnet_pools");
        if (!_infoSubnetPools.equals(_existingSubnetPools)) {
          return new RoomOpenHelper.ValidationResult(false, "subnet_pools(com.alemprator.setup.db.SubnetPool).\n"
                  + " Expected:\n" + _infoSubnetPools + "\n"
                  + " Found:\n" + _existingSubnetPools);
        }
        return new RoomOpenHelper.ValidationResult(true, null);
      }
    }, "135cc93326a68ded21e0e29ddf46dd21", "0d2164c3de5a29b696a31faf83f23491");
    final SupportSQLiteOpenHelper.Configuration _sqliteConfig = SupportSQLiteOpenHelper.Configuration.builder(config.context).name(config.name).callback(_openCallback).build();
    final SupportSQLiteOpenHelper _helper = config.sqliteOpenHelperFactory.create(_sqliteConfig);
    return _helper;
  }

  @Override
  @NonNull
  protected InvalidationTracker createInvalidationTracker() {
    final HashMap<String, String> _shadowTablesMap = new HashMap<String, String>(0);
    final HashMap<String, Set<String>> _viewTables = new HashMap<String, Set<String>>(0);
    return new InvalidationTracker(this, _shadowTablesMap, _viewTables, "devices","subnet_pools");
  }

  @Override
  public void clearAllTables() {
    super.assertNotMainThread();
    final SupportSQLiteDatabase _db = super.getOpenHelper().getWritableDatabase();
    try {
      super.beginTransaction();
      _db.execSQL("DELETE FROM `devices`");
      _db.execSQL("DELETE FROM `subnet_pools`");
      super.setTransactionSuccessful();
    } finally {
      super.endTransaction();
      _db.query("PRAGMA wal_checkpoint(FULL)").close();
      if (!_db.inTransaction()) {
        _db.execSQL("VACUUM");
      }
    }
  }

  @Override
  @NonNull
  protected Map<Class<?>, List<Class<?>>> getRequiredTypeConverters() {
    final HashMap<Class<?>, List<Class<?>>> _typeConvertersMap = new HashMap<Class<?>, List<Class<?>>>();
    _typeConvertersMap.put(DeviceDao.class, DeviceDao_Impl.getRequiredConverters());
    return _typeConvertersMap;
  }

  @Override
  @NonNull
  public Set<Class<? extends AutoMigrationSpec>> getRequiredAutoMigrationSpecs() {
    final HashSet<Class<? extends AutoMigrationSpec>> _autoMigrationSpecsSet = new HashSet<Class<? extends AutoMigrationSpec>>();
    return _autoMigrationSpecsSet;
  }

  @Override
  @NonNull
  public List<Migration> getAutoMigrations(
      @NonNull final Map<Class<? extends AutoMigrationSpec>, AutoMigrationSpec> autoMigrationSpecs) {
    final List<Migration> _autoMigrations = new ArrayList<Migration>();
    return _autoMigrations;
  }

  @Override
  public DeviceDao deviceDao() {
    if (_deviceDao != null) {
      return _deviceDao;
    } else {
      synchronized(this) {
        if(_deviceDao == null) {
          _deviceDao = new DeviceDao_Impl(this);
        }
        return _deviceDao;
      }
    }
  }
}
