
//  // this should be defined in one place -> in Resources, but it can't see it
//  public struct ResourcesStruct {
//      public int cpu_percentage;
//      public double cpu_frequency;
//      public int memory_percentage;
//      public double memory_used;
//      public double memory_total;
//      public int swap_percentage;
//      public double swap_used;
//      public double swap_total;
//  }


[DBus (name = "com.github.stsdc.monitor")]
public interface Monitor.DBusClientInterface : Object {
    public abstract void quit_monitor () throws Error;
    public abstract void show_monitor () throws Error;
    public signal void update (ResourcesSerialized data);
    public signal void indicator_state (bool state);
}

public class Monitor.DBusClient : Object {
    public DBusClientInterface? interface = null;

    private static GLib.Once<DBusClient> instance;
    public static unowned DBusClient get_default () {
        return instance.once (() => { return new DBusClient (); });
    }

    public signal void monitor_vanished ();
    public signal void monitor_appeared ();

    construct {
        try {
            interface = Bus.get_proxy_sync (
                BusType.SESSION,
                "com.github.stsdc.monitor",
                "/com/github/stsdc/monitor"
                );

            Bus.watch_name (
                BusType.SESSION,
                "com.github.stsdc.monitor",
                BusNameWatcherFlags.NONE,
                () => monitor_appeared (),
                () => monitor_vanished ()
            );



        } catch (IOError e) {
            error ("Monitor Indicator DBus: %s\n", e.message);
        }
    }
}
