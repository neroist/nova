## Introduction

Documentation for Nova, a program to control Govee light strips from the
command line.

Not affiliated with Govee.

### Supported Devices

Not all Govee devices are supported by Nova. The devices supported by Nova are:

H6160, H6163, H6104, H6109, H6110, H6117, H6159, H7022, H6086,
H6089, H6182, H6085, H7014, H5081, H6188, H6135, H6137, H6141,
H6142, H6195, H7005, H6083, H6002, H6003, H6148, H6052, H6143,
H6144, H6050, H6199, H6054, H5001, H6154, H6072, H6121, H611A,
H5080, H6062, H614C, H615A, H615B, H7020, H7021, H614D, H611Z,
H611B, H611C, H615C, H615D, H7006, H7007, H7008, H7012, H7013,
H7050, H6051, H6056, H6061, H6058, H6073, H6076, H619A, H619C,
H618A, H618C, H6008, H6071, H6075, H614A, H614B, H614E, H618E,
H619E, H605B, H6087, H6172, H619B, H619D, H619Z, H61A0, H7060,
H610A, H6059, H7028, H6198, H6049, H7031, H7032, H61A1, H61A2,
H61B2, H7061, H6067, H6066, H6009, H7041, H7042, H604A, H6173,
H615E, H604B, H6091, H7051, H7062, H618F, H605D, H6046, H601A,
H61A3, H610B, H6047, H7065, H61E1, H6057, H604C, H6065, H605C,
H705A, H705B, H7055, H61A5, H6078, H604D, H6168, H6601, H70B1,
H61A8, H7121, H7122, H7123, H7120, H7141, H7142, H7130, H7131,
H7132, H7150, H7160, H7101, H7111

Only Wi-Fi devices are supported.

## Important Notes

**Positional arguments are not supported.** For example, `nova color 0 aliceblue`
will not work and will throw an error. You have to explicitly declare every
argument you pass into the command (for example, `nova color -d 0 -c aliceblue`).

In addition, please refrain from calling commands too quickly or frequently.
