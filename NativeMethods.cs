using System.Runtime.InteropServices;
using System; 

namespace AMSI
{
    public enum AMSI_RESULT
    {
        AMSI_RESULT_CLEAN = 0,
        AMSI_RESULT_NOT_DETECTED = 1,
        AMSI_RESULT_DETECTED = 32768
    }

    public static class NativeMethods
    {
        [DllImport("Amsi.dll", EntryPoint = "AmsiInitialize", CallingConvention = CallingConvention.StdCall)]
        public static extern int AmsiInitialize([MarshalAs(UnmanagedType.LPWStr)]string appName, out IntPtr amsiContext);

        [DllImport("Amsi.dll", EntryPoint = "AmsiUninitialize", CallingConvention = CallingConvention.StdCall)]
        public static extern void AmsiUninitialize(IntPtr amsiContext);

        [DllImport("Amsi.dll", EntryPoint = "AmsiOpenSession", CallingConvention = CallingConvention.StdCall)]
        public static extern int AmsiOpenSession(IntPtr amsiContext, out IntPtr session);

        [DllImport("Amsi.dll", EntryPoint = "AmsiCloseSession", CallingConvention = CallingConvention.StdCall)]
        public static extern void AmsiCloseSession(IntPtr amsiContext, IntPtr session);

        [DllImport("Amsi.dll", EntryPoint = "AmsiScanString", CallingConvention = CallingConvention.StdCall)]
        public static extern int AmsiScanString(IntPtr amsiContext, [InAttribute()] [MarshalAsAttribute(UnmanagedType.LPWStr)]string @string, [InAttribute()] [MarshalAsAttribute(UnmanagedType.LPWStr)]string contentName, IntPtr session, out AMSI_RESULT result);
        [DllImport("Amsi.dll", EntryPoint = "AmsiScanBuffer", CallingConvention = CallingConvention.StdCall)]
        public static extern int AmsiScanBuffer(IntPtr amsiContext, byte[] buffer, uint length, string contentName, IntPtr session, out AMSI_RESULT result);
        
        //This method apparently exists on MSDN but not in AMSI.dll (version 4.9.10586.0)
        [DllImport("Amsi.dll", CharSet = CharSet.Unicode, CallingConvention = CallingConvention.StdCall)]
        public static extern bool AmsiResultIsMalware(AMSI_RESULT result);
    } 
}
