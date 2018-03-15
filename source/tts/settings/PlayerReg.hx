package tts.settings;

class PlayerReg {
    public static inline var maxSpeed:Float = 200;
    public static inline var presentMaxSpeed:Float = 100;
    public static inline var iceInertia:Float = 0.03;

    public static inline var freezeLimit:Float = 200;   // Freeze Limit when you get freezed
    public static inline var freezeSpeed:Float = 125;   // How fast you freeze when you get hit
    public static inline var warmUpSpeed:Float = 0.7;   // How fast you warm Up

    public static inline var freezeTimer:Float = 120;   // How long you are freezed
    public static inline var freezeAfter:Float = 50;    // Freeze Value after you where freezed completly

    public static inline var maxSnowball:Int = 3;
    public static inline var minThrowSpeed:Int = 400;
    public static inline var maxThrowSpeed:Int = 800;

    public static inline var pickupDelayAfterDrop:Int = 20;
}