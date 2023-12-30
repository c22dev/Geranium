#include <CoreFoundation/CoreFoundation.h>
#include <mach/machine/kern_return.h>
#include "xpc.h"
#include "connection.h"
#include "bootstrap.h"
#include <stdio.h>
#include <unistd.h>
#include <sys/errno.h>
#include <string.h>

void NSLog(CFStringRef format, ...);

int userspaceReboot(void) {
    kern_return_t ret = 0;
    xpc_object_t xdict = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_uint64(xdict, "cmd", 5);
    ret = unlink("/private/var/mobile/Library/MemoryMaintenance/mmaintenanced");
    if (ret && errno != ENOENT) {
        NSLog(CFSTR("could not delete mmaintenanced last reboot file"));
        return -1;
    }
    xpc_connection_t connection = xpc_connection_create_mach_service("com.apple.mmaintenanced", NULL, 0);
    
    if (xpc_get_type(connection) == XPC_TYPE_ERROR) {
        char* desc = xpc_copy_description(connection);
        NSLog(CFSTR("%s"),desc);
        free(desc);
        xpc_release(connection);
        return -1;
    }
    xpc_connection_set_event_handler(connection, ^(xpc_object_t random) {});
    xpc_connection_activate(connection);
    char* desc = xpc_copy_description(connection);
    puts(desc);
    NSLog(CFSTR("mmaintenanced connection created"));
    xpc_object_t reply = xpc_connection_send_message_with_reply_sync(connection, xdict);
    if (reply) {
        char* desc = xpc_copy_description(reply);
        NSLog(CFSTR("%s"),desc);
        free(desc);
        ret = 0;
    } else {
        NSLog(CFSTR("no reply received from mmaintenanced"));
        ret = -1;
    }
    
    
    xpc_connection_cancel(connection);
    xpc_release(connection);
    xpc_release(reply);
    xpc_release(xdict);
    return ret;
}
