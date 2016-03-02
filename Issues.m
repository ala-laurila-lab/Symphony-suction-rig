% Symphony Issues 

%% What should the preferences be?

%         LastChosenRigConfig: 'EPhysRig'
%                   HekaBusID: 5
%     MultiClamp_SerialNumber: 832113
%          LastChosenProtocol: 'LEDFamily'
%             Ipulse_Defaults: [1x1 struct]
%          LEDFamily_Defaults: [1x1 struct]
%        LastChosenEpochGroup: [1x1 struct]
%        ans.LastChosenEpochGroup
% 
% ans = 
% 
%          label: 'test'
%       keywords: 'test'
%     outputPath: 'C:\Users\local_admin\Acquisition'
%     sourcePath: 'Sources:Mouse
% :Retina
% '
%        mouseID: 'test'
%         cellID: '2'
%        rigName: 'A'
% 

rmpref('MultiClamp')
rmpref('Symphony')


%% Once Matlab freezes, the holding potential is not able to be controlled, I have to restart Matlab, restart symphony, then shut down symphony for it to restart.  Can I do this more simply?


%% Can we control the holding potential both through the Multiclamp commander and the program?

%% What is logging?  Where is the API

%% Removed all of the preferences, 
% began again, left the device dialog open in MultiClamp

%% 11.20a Removed all of the preferences, 
% began again
% opened an epoch group
% ran once
% run #2 froze

%% 11.28a 
% froze immediately

%% 11.37
% froze again

%% 11.39, restart, encountered a problem, output looks like:
% MATLAB crash file:C:\Users\LOCAL_~1\AppData\Local\Temp\matlab_crash_dump.3284-1:
% 
% 
% ------------------------------------------------------------------------
%        Segmentation violation detected at Tue Sep 04 11:38:02 2012
% ------------------------------------------------------------------------
% 
% Configuration:
%   Crash Decoding  : Disabled
%   Default Encoding: windows-1252
%   MATLAB Root     : C:\Program Files\MATLAB\R2012a
%   MATLAB Version  : 7.14.0.739 (R2012a)
%   Operating System: Microsoft Windows 7
%   Processor ID    : x86 Family 6 Model 42 Stepping 7, GenuineIntel
%   Virtual Machine : Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
%   Window System   : Version 6.1 (Build 7601: Service Pack 1)
% 
% Fault Count: 1
% 
% 
% Abnormal termination:
% Segmentation violation
% 
% Register State (from fault):
%   EAX = 00000000  EBX = 25a24ea8
%   ECX = 00000001  EDX = 00000000
%   ESP = 2c9cf2f8  EBP = 2c9cf4c4
%   ESI = 00000000  EDI = 2c9cf3a0
%  
%   EIP = 219f3c5b  EFL = 00010246
%  
%    CS = 0000001b   DS = 00000023   SS = 00000023
%    ES = 00000023   FS = 0000003b   GS = 00000000
% 
% Stack Trace (from fault):
% [  0] 0x219f3c5b h+748468020
% [  1] 0x219f3ab7 h+748468020
% [  2] 0x62e1da21 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02808353 ???+000000
% [  3] 0x62deb692 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02602642 ???+000000
% [  4] 0x62deaf1f C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600735 ???+000000
% [  5] 0x62deadc5 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600389 ???+000000
% [  6] 0x6bc221bb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00008635 ???+000000
% [  7] 0x6bc54227 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213543 ( LogHelp_TerminateOnAssert+089711 )
% [  8] 0x6bc543c4 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213956 ( LogHelp_TerminateOnAssert+090124 )
% [  9] 0x6bc543f9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00214009 ( LogHelp_TerminateOnAssert+090177 )
% [ 10] 0x6bda88fd C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607933 ( GetPrivateContextsPerfCounters+147354 )
% [ 11] 0x6bdcaf7c C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748860 ( GetPrivateContextsPerfCounters+288281 )
% [ 12] 0x6bdcaffe C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748990 ( GetPrivateContextsPerfCounters+288411 )
% [ 13] 0x6bdcb0b9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749177 ( GetPrivateContextsPerfCounters+288598 )
% [ 14] 0x6bdcb151 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749329 ( GetPrivateContextsPerfCounters+288750 )
% [ 15] 0x6bdab171 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01618289 ( GetPrivateContextsPerfCounters+157710 )
% [ 16] 0x6bda883b C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607739 ( GetPrivateContextsPerfCounters+147160 )
% [ 17] 0x6bdaacfb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01617147 ( GetPrivateContextsPerfCounters+156568 )
% [ 18] 0x6bdac55d C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01623389 ( GetPrivateContextsPerfCounters+162810 )
% [ 19] 0x6bce8e48 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00822856 ( GetCLRFunction+079989 )
% [ 20] 0x76c9ed6c                   C:\Windows\system32\kernel32.dll+00322924 ( BaseThreadInitThunk+000018 )
% [ 21] 0x76e2377b                      C:\Windows\SYSTEM32\ntdll.dll+00407419 ( RtlInitializeExceptionChain+000239 )
% [ 22] 0x76e2374e                      C:\Windows\SYSTEM32\ntdll.dll+00407374 ( RtlInitializeExceptionChain+000194 )
% 
% 
% If this problem is reproducible, please submit a Service Request via:
%     http://www.mathworks.com/support/contact_us/
% 
% A technical support engineer might contact you with further information.
% 
% Thank you for your help.

%% 11.42 - Start symphony, same problem!
% MATLAB crash file:C:\Users\LOCAL_~1\AppData\Local\Temp\matlab_crash_dump.4364-1:
% 
% 
% ------------------------------------------------------------------------
%        Segmentation violation detected at Tue Sep 04 11:40:41 2012
% ------------------------------------------------------------------------
% 
% Configuration:
%   Crash Decoding  : Disabled
%   Default Encoding: windows-1252
%   MATLAB Root     : C:\Program Files\MATLAB\R2012a
%   MATLAB Version  : 7.14.0.739 (R2012a)
%   Operating System: Microsoft Windows 7
%   Processor ID    : x86 Family 6 Model 42 Stepping 7, GenuineIntel
%   Virtual Machine : Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
%   Window System   : Version 6.1 (Build 7601: Service Pack 1)
% 
% Fault Count: 1
% 
% 
% Abnormal termination:
% Segmentation violation
% 
% Register State (from fault):
%   EAX = 00000000  EBX = 25794ea8
%   ECX = 00000001  EDX = 00000000
%   ESP = 2c95f278  EBP = 2c95f444
%   ESI = 00000000  EDI = 2c95f320
%  
%   EIP = 084a3c5b  EFL = 00010246
%  
%    CS = 0000001b   DS = 00000023   SS = 00000023
%    ES = 00000023   FS = 0000003b   GS = 00000000
% 
% Stack Trace (from fault):
% [  0] 0x084a3c5b h+748009140
% [  1] 0x084a3ab7 h+748009140
% [  2] 0x62e1da21 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02808353 ???+000000
% [  3] 0x62deb692 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02602642 ???+000000
% [  4] 0x62deaf1f C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600735 ???+000000
% [  5] 0x62deadc5 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600389 ???+000000
% [  6] 0x6bc221bb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00008635 ???+000000
% [  7] 0x6bc54227 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213543 ( LogHelp_TerminateOnAssert+089711 )
% [  8] 0x6bc543c4 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213956 ( LogHelp_TerminateOnAssert+090124 )
% [  9] 0x6bc543f9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00214009 ( LogHelp_TerminateOnAssert+090177 )
% [ 10] 0x6bda88fd C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607933 ( GetPrivateContextsPerfCounters+147354 )
% [ 11] 0x6bdcaf7c C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748860 ( GetPrivateContextsPerfCounters+288281 )
% [ 12] 0x6bdcaffe C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748990 ( GetPrivateContextsPerfCounters+288411 )
% [ 13] 0x6bdcb0b9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749177 ( GetPrivateContextsPerfCounters+288598 )
% [ 14] 0x6bdcb151 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749329 ( GetPrivateContextsPerfCounters+288750 )
% [ 15] 0x6bdab171 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01618289 ( GetPrivateContextsPerfCounters+157710 )
% [ 16] 0x6bda883b C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607739 ( GetPrivateContextsPerfCounters+147160 )
% [ 17] 0x6bdaacfb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01617147 ( GetPrivateContextsPerfCounters+156568 )
% [ 18] 0x6bdac55d C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01623389 ( GetPrivateContextsPerfCounters+162810 )
% [ 19] 0x6bce8e48 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00822856 ( GetCLRFunction+079989 )
% [ 20] 0x76c9ed6c                   C:\Windows\system32\kernel32.dll+00322924 ( BaseThreadInitThunk+000018 )
% [ 21] 0x76e2377b                      C:\Windows\SYSTEM32\ntdll.dll+00407419 ( RtlInitializeExceptionChain+000239 )
% [ 22] 0x76e2374e                      C:\Windows\SYSTEM32\ntdll.dll+00407374 ( RtlInitializeExceptionChain+000194 )
% 
% 
% If this problem is reproducible, please submit a Service Request via:
%     http://www.mathworks.com/support/contact_us/
% 
% A technical support engineer might contact you with further information.
% 
% Thank you for your help.

%% 11.42
% StartSymphony
% Unplugged everything, restarted
% MultiClamp pref is empty...
setpref('MultiClamp','SerialNumber',832113)
% but MultiClamp_SerialNumber is still there.

%% 11.52 
% begin again

% MATLAB crash file:C:\Users\LOCAL_~1\AppData\Local\Temp\matlab_crash_dump.4276-1:
% 
% 
% ------------------------------------------------------------------------
%        Segmentation violation detected at Tue Sep 04 11:52:37 2012
% ------------------------------------------------------------------------
% 
% Configuration:
%   Crash Decoding  : Disabled
%   Default Encoding: windows-1252
%   MATLAB Root     : C:\Program Files\MATLAB\R2012a
%   MATLAB Version  : 7.14.0.739 (R2012a)
%   Operating System: Microsoft Windows 7
%   Processor ID    : x86 Family 6 Model 42 Stepping 7, GenuineIntel
%   Virtual Machine : Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
%   Window System   : Version 6.1 (Build 7601: Service Pack 1)
% 
% Fault Count: 1
% 
% 
% Abnormal termination:
% Segmentation violation
% 
% Register State (from fault):
%   EAX = 0c93efd8  EBX = 00000000
%   ECX = ff48ff3a  EDX = 0c93ed00
%   ESP = 2921f9c4  EBP = 2921faa4
%   ESI = 0c93ecf8  EDI = 0cb00000
%  
%   EIP = 76e163f8  EFL = 00010297
%  
%    CS = 0000001b   DS = 00000023   SS = 00000023
%    ES = 00000023   FS = 0000003b   GS = 00000000
% 
% Stack Trace (from fault):
% [  0] 0x76e163f8                      C:\Windows\SYSTEM32\ntdll.dll+00353272 ( wcsnicmp+002924 )
% [  1] 0x76e16536                      C:\Windows\SYSTEM32\ntdll.dll+00353590 ( wcsnicmp+003242 )
% [  2] 0x76c9c3d4                   C:\Windows\system32\kernel32.dll+00312276 ( HeapFree+000020 )
% [  3] 0x720a016a                   C:\Windows\system32\MSVCR100.dll+00065898 ( free+000028 )
% [  4] 0x720a28be                   C:\Windows\system32\MSVCR100.dll+00075966 ( freefls+000219 )
% [  5] 0x76e1d690                      C:\Windows\SYSTEM32\ntdll.dll+00382608 ( RtlClearBits+000728 )
% [  6] 0x76def684                      C:\Windows\SYSTEM32\ntdll.dll+00194180 ( LdrShutdownThread+000053 )
% [  7] 0x76def632                      C:\Windows\SYSTEM32\ntdll.dll+00194098 ( RtlExitUserThread+000042 )
% [  8] 0x7d9194f5 C:\Program Files\MATLAB\R2012a\bin\win32\MSVCR71.dll+00038133 ( endthreadex+000048 )
% [  9] 0x76c9ed6c                   C:\Windows\system32\kernel32.dll+00322924 ( BaseThreadInitThunk+000018 )
% [ 10] 0x76e2377b                      C:\Windows\SYSTEM32\ntdll.dll+00407419 ( RtlInitializeExceptionChain+000239 )
% [ 11] 0x76e2374e                      C:\Windows\SYSTEM32\ntdll.dll+00407374 ( RtlInitializeExceptionChain+000194 )
% 
% 
% If this problem is reproducible, please submit a Service Request via:
%     http://www.mathworks.com/support/contact_us/
% 
% A technical support engineer might contact you with further information.
% 
% Thank you for your help.

%% Crap! 14.24 dump

% ------------------------------------------------------------------------
%        Segmentation violation detected at Tue Sep 04 14:25:02 2012
% ------------------------------------------------------------------------
% 
% Configuration:
%   Crash Decoding  : Disabled
%   Default Encoding: windows-1252
%   MATLAB Root     : C:\Program Files\MATLAB\R2012a
%   MATLAB Version  : 7.14.0.739 (R2012a)
%   Operating System: Microsoft Windows 7
%   Processor ID    : x86 Family 6 Model 42 Stepping 7, GenuineIntel
%   Virtual Machine : Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
%   Window System   : Version 6.1 (Build 7601: Service Pack 1)
% 
% Fault Count: 1
% 
% 
% Abnormal termination:
% Segmentation violation
% 
% Register State (from fault):
%   EAX = 00000000  EBX = 26224ea8
%   ECX = 00000001  EDX = 00000000
%   ESP = 2cdbf218  EBP = 2cdbf3e4
%   ESI = 00000000  EDI = 2cdbf2c0
%  
%   EIP = 08113c5b  EFL = 00010246
%  
%    CS = 0000001b   DS = 00000023   SS = 00000023
%    ES = 00000023   FS = 0000003b   GS = 00000000
%
%
% Stack Trace (from fault):
% [  0] 0x08113c5b h+752596596
% [  1] 0x08113ab7 h+752596596
% [  2] 0x62e1da21 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02808353 ???+000000
% [  3] 0x62deb692 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02602642 ???+000000
% [  4] 0x62deaf1f C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600735 ???+000000
% [  5] 0x62deadc5 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600389 ???+000000
% [  6] 0x6bc221bb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00008635 ???+000000
% [  7] 0x6bc54227 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213543 ( LogHelp_TerminateOnAssert+089711 )
% [  8] 0x6bc543c4 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213956 ( LogHelp_TerminateOnAssert+090124 )
% [  9] 0x6bc543f9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00214009 ( LogHelp_TerminateOnAssert+090177 )
% [ 10] 0x6bda88fd C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607933 ( GetPrivateContextsPerfCounters+147354 )
% [ 11] 0x6bdcaf7c C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748860 ( GetPrivateContextsPerfCounters+288281 )
% [ 12] 0x6bdcaffe C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748990 ( GetPrivateContextsPerfCounters+288411 )
% [ 13] 0x6bdcb0b9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749177 ( GetPrivateContextsPerfCounters+288598 )
% [ 14] 0x6bdcb151 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749329 ( GetPrivateContextsPerfCounters+288750 )
% [ 15] 0x6bdab171 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01618289 ( GetPrivateContextsPerfCounters+157710 )
% [ 16] 0x6bda883b C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607739 ( GetPrivateContextsPerfCounters+147160 )
% [ 17] 0x6bdaacfb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01617147 ( GetPrivateContextsPerfCounters+156568 )
% [ 18] 0x6bdac55d C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01623389 ( GetPrivateContextsPerfCounters+162810 )
% [ 19] 0x6bce8e48 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00822856 ( GetCLRFunction+079989 )
% [ 20] 0x76c9ed6c                   C:\Windows\system32\kernel32.dll+00322924 ( BaseThreadInitThunk+000018 )
% [ 21] 0x76e2377b                      C:\Windows\SYSTEM32\ntdll.dll+00407419 ( RtlInitializeExceptionChain+000239 )
% [ 22] 0x76e2374e                      C:\Windows\SYSTEM32\ntdll.dll+00407374 ( RtlInitializeExceptionChain+000194 )
% 
% 
% If this problem is reproducible, please submit a Service Request via:
%     http://www.mathworks.com/support/contact_us/
% 
% A technical support engineer might contact you with further information.
% 
% Thank you for your help.

%% Note, the Serial number is back to ''

%%
% ------------------------------------------------------------------------
%        Segmentation violation detected at Tue Sep 04 14:32:34 2012
% ------------------------------------------------------------------------
% 
% Configuration:
%   Crash Decoding  : Disabled
%   Default Encoding: windows-1252
%   MATLAB Root     : C:\Program Files\MATLAB\R2012a
%   MATLAB Version  : 7.14.0.739 (R2012a)
%   Operating System: Microsoft Windows 7
%   Processor ID    : x86 Family 6 Model 42 Stepping 7, GenuineIntel
%   Virtual Machine : Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
%   Window System   : Version 6.1 (Build 7601: Service Pack 1)
% 
% Fault Count: 1
% 
% 
% Abnormal termination:
% Segmentation violation
% 
% Register State (from fault):
%   EAX = 00000000  EBX = 262e4ea8
%   ECX = 00000001  EDX = 00000000
%   ESP = 2d02f388  EBP = 2d02f554
%   ESI = 00000000  EDI = 2d02f430
%  
%   EIP = 0c623b7b  EFL = 00010246
%  
%    CS = 0000001b   DS = 00000023   SS = 00000023
%    ES = 00000023   FS = 0000003b   GS = 00000000
% 
% Stack Trace (from fault):
% [  0] 0x0c623b7b h+755152884
% [  1] 0x0c623ab7 h+755152884
% [  2] 0x62e1da21 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02808353 ???+000000
% [  3] 0x62deb692 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02602642 ???+000000
% [  4] 0x62deaf1f C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600735 ???+000000
% [  5] 0x62deadc5 C:\Windows\assembly\NativeImages_v4.0.30319_32\mscorlib\3953b1d8b9b57e4957bff8f58145384e\mscorlib.ni.dll+02600389 ???+000000
% [  6] 0x6bc221bb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00008635 ???+000000
% [  7] 0x6bc54227 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213543 ( LogHelp_TerminateOnAssert+089711 )
% [  8] 0x6bc543c4 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00213956 ( LogHelp_TerminateOnAssert+090124 )
% [  9] 0x6bc543f9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00214009 ( LogHelp_TerminateOnAssert+090177 )
% [ 10] 0x6bda88fd C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607933 ( GetPrivateContextsPerfCounters+147354 )
% [ 11] 0x6bdcaf7c C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748860 ( GetPrivateContextsPerfCounters+288281 )
% [ 12] 0x6bdcaffe C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01748990 ( GetPrivateContextsPerfCounters+288411 )
% [ 13] 0x6bdcb0b9 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749177 ( GetPrivateContextsPerfCounters+288598 )
% [ 14] 0x6bdcb151 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01749329 ( GetPrivateContextsPerfCounters+288750 )
% [ 15] 0x6bdab171 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01618289 ( GetPrivateContextsPerfCounters+157710 )
% [ 16] 0x6bda883b C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01607739 ( GetPrivateContextsPerfCounters+147160 )
% [ 17] 0x6bdaacfb C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01617147 ( GetPrivateContextsPerfCounters+156568 )
% [ 18] 0x6bdac55d C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+01623389 ( GetPrivateContextsPerfCounters+162810 )
% [ 19] 0x6bce8e48 C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll+00822856 ( GetCLRFunction+079989 )
% [ 20] 0x76c9ed6c                   C:\Windows\system32\kernel32.dll+00322924 ( BaseThreadInitThunk+000018 )
% [ 21] 0x76e2377b                      C:\Windows\SYSTEM32\ntdll.dll+00407419 ( RtlInitializeExceptionChain+000239 )
% [ 22] 0x76e2374e                      C:\Windows\SYSTEM32\ntdll.dll+00407374 ( RtlInitializeExceptionChain+000194 )
% 
% 
% If this problem is reproducible, please submit a Service Request via:
%     http://www.mathworks.com/support/contact_us/
% 
% A technical support engineer might contact you with further information.
% 
% Thank you for your help.