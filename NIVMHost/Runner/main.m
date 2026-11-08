#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreFoundation/CoreFoundation.h>
#import <dlfcn.h>
#import <objc/message.h>
#import <objc/runtime.h>
#include <mach/mach.h>
#include <mach/arm/thread_status.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <libgen.h>
#include <signal.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <errno.h>
#include <execinfo.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/ucontext.h>
#include <unistd.h>

typedef void (*AijinNUDGuestHooksInitFunction)(void);
typedef void (*AijinPBPlayerSetupAppFunction)(void);
typedef void *(*AijinAdversarysOpenFunction)(const char *, const char *);
typedef void *(*AijinAdversarysOpenLooseFunction)(const char *);
typedef void *(*AijinAdversarysSymbolFunction)(void *, const char *);
typedef const char *(*AijinAdversarysErrorFunction)(void);
typedef void (*AijinAdversarysClassFunction)(const char *);
typedef void (*AijinAdversarysAbortFunction)(int);
typedef void (*AijinAdversarysHandlerFunction)(void (*)(const char *));
typedef void (*AijinSwiftRegisterRangeFunction)(const void *, const void *);

extern void AijinProbeLNKiwiDecrypt(const char *input);

static AijinNUDGuestHooksInitFunction AijinNUDGuestHooksInit;
static AijinPBPlayerSetupAppFunction AijinPBPlayerSetupApp;
static AijinAdversarysOpenFunction AijinAdversarysOpen;
static AijinAdversarysOpenLooseFunction AijinAdversarysOpenLoose;
static AijinAdversarysSymbolFunction AijinAdversarysSymbol;
static AijinAdversarysErrorFunction AijinAdversarysError;
static AijinAdversarysClassFunction AijinAdversarysClass;
static AijinAdversarysAbortFunction AijinAdversarysAbort;
static AijinAdversarysHandlerFunction AijinAdversarysHandler;
static uintptr_t AijinDiagnosticAdversarysBase;
static int AijinDiagnosticSignalFile = -1;
static BOOL AijinDiagnosticSignalHandlerInstalled;
static BOOL AijinDiagnosticDispatchOnceArmed;
static volatile sig_atomic_t AijinDiagnosticWatchArmed;
static uintptr_t AijinDiagnosticWatchAddress;
static uintptr_t AijinDiagnosticWatchGuestState;
static volatile sig_atomic_t AijinDiagnosticSampleCount;
static const sig_atomic_t AijinDiagnosticSampleLimit = 5000;
static volatile int AijinDiagnosticBurstStarted;
static volatile int AijinDiagnosticFileBurstStarted;
static volatile int AijinDiagnosticFocusedBurstStarted;
static BOOL AijinDiagnosticFirstFrameHooked;
static IMP AijinOriginalKiwiInitWithListener;
static Class AijinNativeKiwiClass;
static IMP AijinNativeKiwiInit;
static IMP AijinOriginalDyzbKiwiInitEx;
static Class AijinNativeYunCengPluginClass;
static Class AijinNativeFlutterMethodChannelClass;
static char AijinNativeYunCengPluginAssociationKey;
static char AijinNativeYunCengTokenAssociationKey;
static char AijinNativeYunCengChannelAssociationKey;
static char AijinNativeYunCengHandlerAssociationKey;
static void AijinInstallGuestFloatingControl(UIWindow *window);
static BOOL AijinInProcessGuestBootstrap;
static id AijinInProcessGuestDelegate;
static UIWindow *AijinInProcessGuestWindow;
static UIViewController *AijinInProcessGuestRootController;
typedef NS_ENUM(NSInteger, AijinGuestLifecycleState) {
  AijinGuestLifecycleStateUnavailable = 0,
  AijinGuestLifecycleStateActive,
  AijinGuestLifecycleStateInactive,
  AijinGuestLifecycleStateBackground,
};
static BOOL AijinInProcessGuestLifecycleReady;
static AijinGuestLifecycleState AijinInProcessGuestLifecycleState;
static NSBundle *AijinHostBundle;
static NSBundle *AijinGuestMainBundle;
static CFBundleRef AijinGuestMainCFBundle;
static NSMutableArray *AijinGuestIdentityKeepAliveObjects;
static NSBundle *AijinPreviousMainBundle;
static CFBundleRef AijinPreviousMainCFBundle;
static void **AijinMainNSBundleStorage;
static void **AijinMainCFBundleStorage;
static NSString *AijinPreviousArgumentZero;
static NSString *AijinPreviousProcessName;
static vm_prot_t AijinMainNSBundleProtection = VM_PROT_NONE;
static vm_prot_t AijinMainCFBundleProtection = VM_PROT_NONE;
static BOOL AijinMainNSBundleMappingTainted;
static BOOL AijinMainCFBundleMappingTainted;
static id AijinHostApplicationDelegate;
static UIWindow *AijinHostApplicationWindow;
static UIViewController *AijinHostRootViewController;
static BOOL AijinHostWindowWasHidden;
static BOOL AijinHostWindowWasKey;
static BOOL AijinHostApplicationSurfaceCaptured;
static NSUInteger AijinGuestLaunchGeneration;
static BOOL AijinGuestRuntimeIrreversible;
static volatile int AijinGuestRuntimeLaunchClaim;
static NSMutableArray<NSValue *> *AijinLooseGuestImages;
static uintptr_t AijinChungongKingfisherBase;

typedef struct {
  uintptr_t value;
  uintptr_t state;
} AijinChungongMetadataResponse;

typedef AijinChungongMetadataResponse
    (*AijinSwiftGetGenericMetadataFunction)(
        uintptr_t, const void *const *, const void *);

static AijinSwiftGetGenericMetadataFunction
    AijinChungongSwiftGetGenericMetadata;
static const void *AijinChungongKingfisherWrapperDescriptor;
typedef AijinChungongMetadataResponse
    (*AijinSwiftGetSingletonMetadataFunction)(uintptr_t, const void *);
static AijinSwiftGetSingletonMetadataFunction
    AijinChungongSwiftGetSingletonMetadata;
static const void *AijinChungongKingfisherImageResourceDescriptor;

static AijinChungongMetadataResponse
AijinChungongKingfisherWrapperMetadataAccessor(
    uintptr_t request, const void *argument0, const void *argument1,
    const void *argument2) {
  if (AijinChungongSwiftGetGenericMetadata == NULL ||
      AijinChungongKingfisherWrapperDescriptor == NULL) {
    AijinChungongMetadataResponse failure = {0, 0};
    return failure;
  }
  const void *arguments[3] = {argument0, argument1, argument2};
  return AijinChungongSwiftGetGenericMetadata(
      request, arguments, AijinChungongKingfisherWrapperDescriptor);
}

static AijinChungongMetadataResponse
AijinChungongKingfisherImageResourceMetadataAccessor(uintptr_t request) {
  if (AijinChungongKingfisherBase == 0 ||
      AijinChungongSwiftGetSingletonMetadata == NULL ||
      AijinChungongKingfisherImageResourceDescriptor == NULL) {
    AijinChungongMetadataResponse failure = {0, 0};
    return failure;
  }
  const void *cached = *(const void *const *)(
      AijinChungongKingfisherBase + 0x000D63F0);
  if (cached != NULL) {
    AijinChungongMetadataResponse response = {
        (uintptr_t)cached, 0};
    return response;
  }
  return AijinChungongSwiftGetSingletonMetadata(
      request, AijinChungongKingfisherImageResourceDescriptor);
}

static AijinChungongMetadataResponse
AijinChungongKingfisherDownloadTaskMetadataAccessor(uintptr_t request) {
  (void)request;
  AijinChungongMetadataResponse response = {
      AijinChungongKingfisherBase + 0x000C8F68, 0};
  return response;
}

typedef struct {
  AijinSwiftRegisterRangeFunction registerProtocols;
  AijinSwiftRegisterRangeFunction registerConformances;
  AijinSwiftRegisterRangeFunction registerTypes;
  NSUInteger images;
  NSUInteger protocolSections;
  NSUInteger conformanceSections;
  NSUInteger typeSections;
} AijinSwiftRegistrationContext;

static BOOL AijinMachONameEquals(const char rawName[16],
                                  const char *expected) {
  size_t length = strlen(expected);
  return length <= 16 && memcmp(rawName, expected, length) == 0 &&
      (length == 16 || rawName[length] == '\0');
}

static BOOL AijinRegisterSwiftMetadataForImage(
    uintptr_t headerAddress,
    uintptr_t allowedStart,
    uintptr_t allowedEnd,
    AijinSwiftRegistrationContext *context) {
  const struct mach_header_64 *header =
      (const struct mach_header_64 *)headerAddress;
  if (header->magic != MH_MAGIC_64 || header->cputype != CPU_TYPE_ARM64 ||
      (header->filetype != MH_EXECUTE && header->filetype != MH_DYLIB &&
       header->filetype != MH_BUNDLE) ||
      header->ncmds == 0 || header->ncmds > 1024 ||
      header->sizeofcmds > 0x20000) {
    return NO;
  }

  const uint8_t *commands = (const uint8_t *)(header + 1);
  const uint8_t *commandsEnd = commands + header->sizeofcmds;
  const struct segment_command_64 *textSegment = NULL;
  for (uint32_t index = 0; index < header->ncmds; index++) {
    if (commands + sizeof(struct load_command) > commandsEnd) {
      return NO;
    }
    const struct load_command *command =
        (const struct load_command *)commands;
    if (command->cmdsize < sizeof(struct load_command) ||
        commands + command->cmdsize > commandsEnd) {
      return NO;
    }
    if (command->cmd == LC_SEGMENT_64 &&
        command->cmdsize >= sizeof(struct segment_command_64)) {
      const struct segment_command_64 *segment =
          (const struct segment_command_64 *)command;
      if (AijinMachONameEquals(segment->segname, SEG_TEXT) &&
          segment->fileoff == 0) {
        textSegment = segment;
      }
    }
    commands += command->cmdsize;
  }
  if (textSegment == NULL || textSegment->vmaddr > headerAddress) {
    return NO;
  }

  uintptr_t slide = headerAddress - (uintptr_t)textSegment->vmaddr;
  commands = (const uint8_t *)(header + 1);
  BOOL registeredImage = NO;
  for (uint32_t index = 0; index < header->ncmds; index++) {
    const struct load_command *command =
        (const struct load_command *)commands;
    if (command->cmd == LC_SEGMENT_64 &&
        command->cmdsize >= sizeof(struct segment_command_64)) {
      const struct segment_command_64 *segment =
          (const struct segment_command_64 *)command;
      size_t requiredSize = sizeof(struct segment_command_64) +
          (size_t)segment->nsects * sizeof(struct section_64);
      if (requiredSize > command->cmdsize) {
        return NO;
      }
      const struct section_64 *sections =
          (const struct section_64 *)(segment + 1);
      for (uint32_t sectionIndex = 0;
           sectionIndex < segment->nsects;
           sectionIndex++) {
        const struct section_64 *section = &sections[sectionIndex];
        if (section->size == 0 || section->addr > UINTPTR_MAX - slide) {
          continue;
        }
        uintptr_t beginAddress = slide + (uintptr_t)section->addr;
        if (beginAddress < allowedStart || beginAddress >= allowedEnd ||
            section->size > allowedEnd - beginAddress) {
          continue;
        }
        const void *begin = (const void *)beginAddress;
        const void *end = (const void *)(beginAddress + section->size);
        if (AijinMachONameEquals(section->sectname, "__swift5_protos") &&
            context->registerProtocols != NULL) {
          context->registerProtocols(begin, end);
          context->protocolSections++;
          registeredImage = YES;
        } else if (AijinMachONameEquals(section->sectname,
                                         "__swift5_proto") &&
                   context->registerConformances != NULL) {
          context->registerConformances(begin, end);
          context->conformanceSections++;
          registeredImage = YES;
        } else if (AijinMachONameEquals(section->sectname,
                                         "__swift5_types") &&
                   context->registerTypes != NULL) {
          context->registerTypes(begin, end);
          context->typeSections++;
          registeredImage = YES;
        }
      }
    }
    commands += command->cmdsize;
  }
  if (registeredImage) {
    context->images++;
  }
  return registeredImage;
}

static BOOL AijinRegisterMappedGuestSwiftMetadata(void) {
  if (AijinDiagnosticAdversarysBase == 0) {
    NSLog(@"AIJIN_SWIFT_METADATA registration_failed reason=runtime_base");
    return NO;
  }
  AijinSwiftRegistrationContext context = {
    .registerProtocols = (AijinSwiftRegisterRangeFunction)dlsym(
        RTLD_DEFAULT, "swift_registerProtocols"),
    .registerConformances = (AijinSwiftRegisterRangeFunction)dlsym(
        RTLD_DEFAULT, "swift_registerProtocolConformances"),
    .registerTypes = (AijinSwiftRegisterRangeFunction)dlsym(
        RTLD_DEFAULT, "swift_registerTypeMetadataRecords"),
  };
  if (context.registerConformances == NULL) {
    NSLog(@"AIJIN_SWIFT_METADATA registration_failed reason=runtime_api");
    return NO;
  }

  uintptr_t allowedStart = AijinDiagnosticAdversarysBase + 0x05000000;
  uintptr_t allowedEnd = AijinDiagnosticAdversarysBase + 0x10000000;
  uintptr_t page =
      (allowedStart + vm_page_size - 1) & ~(uintptr_t)(vm_page_size - 1);
  for (; page + sizeof(struct mach_header_64) <= allowedEnd;
       page += vm_page_size) {
    const struct mach_header_64 *header =
        (const struct mach_header_64 *)page;
    if (header->magic == MH_MAGIC_64) {
      AijinRegisterSwiftMetadataForImage(
          page, allowedStart, allowedEnd, &context);
    }
  }
  NSLog(@"AIJIN_SWIFT_METADATA registered images=%lu protocols=%lu "
        "conformances=%lu types=%lu",
        (unsigned long)context.images,
        (unsigned long)context.protocolSections,
        (unsigned long)context.conformanceSections,
        (unsigned long)context.typeSections);
  return context.conformanceSections > 0;
}

static const struct mach_header_64 *AijinMappedChungongMainImageHeader(void) {
  if (AijinDiagnosticAdversarysBase == 0) {
    return NULL;
  }
  uintptr_t allowedStart = AijinDiagnosticAdversarysBase + 0x05000000;
  uintptr_t allowedEnd = AijinDiagnosticAdversarysBase + 0x10000000;
  uintptr_t page =
      (allowedStart + vm_page_size - 1) & ~(uintptr_t)(vm_page_size - 1);
  for (; page + sizeof(struct mach_header_64) <= allowedEnd;
       page += vm_page_size) {
    const struct mach_header_64 *header =
        (const struct mach_header_64 *)page;
    if (header->magic == MH_MAGIC_64 && header->filetype == MH_EXECUTE) {
      return header;
    }
  }
  return NULL;
}

static const struct mach_header_64 *AijinMappedGuestDylibHeaderWithSuffix(
    const char *suffix) {
  if (AijinDiagnosticAdversarysBase == 0 || suffix == NULL) {
    return NULL;
  }
  uintptr_t allowedStart = AijinDiagnosticAdversarysBase + 0x05000000;
  uintptr_t allowedEnd = AijinDiagnosticAdversarysBase + 0x10000000;
  uintptr_t page =
      (allowedStart + vm_page_size - 1) & ~(uintptr_t)(vm_page_size - 1);
  size_t suffixLength = strlen(suffix);
  for (; page + sizeof(struct mach_header_64) <= allowedEnd;
       page += vm_page_size) {
    const struct mach_header_64 *header =
        (const struct mach_header_64 *)page;
    if (header->magic != MH_MAGIC_64 || header->filetype != MH_DYLIB ||
        header->ncmds == 0 || header->ncmds > 1024 ||
        header->sizeofcmds > 0x20000) {
      continue;
    }
    const uint8_t *cursor = (const uint8_t *)(header + 1);
    const uint8_t *commandsEnd = cursor + header->sizeofcmds;
    for (uint32_t index = 0; index < header->ncmds; index++) {
      if (cursor + sizeof(struct load_command) > commandsEnd) {
        break;
      }
      const struct load_command *command =
          (const struct load_command *)cursor;
      if (command->cmdsize < sizeof(struct load_command) ||
          cursor + command->cmdsize > commandsEnd) {
        break;
      }
      if (command->cmd == LC_ID_DYLIB &&
          command->cmdsize >= sizeof(struct dylib_command)) {
        const struct dylib_command *dylib =
            (const struct dylib_command *)command;
        uint32_t nameOffset = dylib->dylib.name.offset;
        if (nameOffset < command->cmdsize) {
          const char *name = (const char *)cursor + nameOffset;
          size_t maximumLength = command->cmdsize - nameOffset;
          size_t length = strnlen(name, maximumLength);
          if (length >= suffixLength && length < maximumLength &&
              memcmp(name + length - suffixLength, suffix, suffixLength) == 0) {
            return header;
          }
        }
      }
      cursor += command->cmdsize;
    }
  }
  return NULL;
}

static BOOL AijinPrewarmChungongKingfisherWrapperMetadata(void) {
  const struct mach_header_64 *header =
      AijinMappedGuestDylibHeaderWithSuffix(
          "Kingfisher.framework/Kingfisher");
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_failed "
          "reason=image_missing");
    return NO;
  }

  // Kingfisher.Wrapper<UIImageView>'s descriptor is at VM 0xb6880 and its
  // metadata-accessor relative field is twelve bytes into that descriptor.
  // Seal first asks for this specialization from the translated tab
  // controller's viewDidLoad.  Letting native Swift instantiate it there
  // calls a mapped Kingfisher completion thunk while adversarys already owns
  // an active guest frame.  Prime the identical cache key before entering
  // viewDidLoad so the translated accessor takes Swift's cached fast path.
  // Call swift_getGenericMetadata directly: entering the translated accessor
  // first would itself create an adversarys frame and merely move the same
  // non-reentrant callback one level earlier.
  uintptr_t fieldAddress = (uintptr_t)header + 0x000B688C;
  int32_t relativeTarget = 0;
  memcpy(&relativeTarget, (const void *)fieldAddress, sizeof(relativeTarget));
  uintptr_t targetAddress = fieldAddress + (intptr_t)relativeTarget;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  uintptr_t nativeTarget =
      (uintptr_t)(void *)&AijinChungongKingfisherWrapperMetadataAccessor;
  BOOL targetIsRuntimeThunk =
      targetAddress >= runtimeStart &&
      targetAddress < runtimeStart + 0x05000000;
  if (!targetIsRuntimeThunk && targetAddress != nativeTarget) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)targetAddress);
    return NO;
  }

  typedef const void *(*SwiftGetObjCClassMetadataFunction)(Class);
  SwiftGetObjCClassMetadataFunction getObjCClassMetadata =
      (SwiftGetObjCClassMetadataFunction)dlsym(
          RTLD_DEFAULT, "swift_getObjCClassMetadata");
  if (getObjCClassMetadata == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_failed "
          "reason=objc_metadata_api");
    return NO;
  }
  const void *imageViewMetadata =
      getObjCClassMetadata([UIImageView class]);
  if (imageViewMetadata == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_failed "
          "reason=image_view_metadata");
    return NO;
  }

  AijinSwiftGetGenericMetadataFunction getGenericMetadata =
      (AijinSwiftGetGenericMetadataFunction)dlsym(
          RTLD_DEFAULT, "swift_getGenericMetadata");
  if (getGenericMetadata == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_failed "
          "reason=generic_metadata_api");
    return NO;
  }
  const void *arguments[3] = {imageViewMetadata, NULL, NULL};
  const void *descriptor = (const void *)((uintptr_t)header + 0x000B6880);
  NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_prewarm_start "
        "field=%p target=%p descriptor=%p argument=%p",
        (void *)fieldAddress, (void *)targetAddress, descriptor,
        imageViewMetadata);
  AijinChungongMetadataResponse response =
      getGenericMetadata(0xFF, arguments, descriptor);
  if (response.value == 0) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_failed "
          "reason=nil_result");
    return NO;
  }
  NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_metadata_prewarm_done "
        "value=%p state=%p",
        (void *)response.value, (void *)response.state);
  return YES;
}

enum {
  AijinChungongKingfisherWrapperMetadataStubOffset = 0x0088BB28,
  AijinChungongKingfisherImageResourceMetadataStubOffset = 0x0088BB40,
  AijinChungongKingfisherDownloadTaskMetadataStubOffset = 0x0088BB58,
  AijinChungongKingfisherWrapperMetadataSlotOffset = 0x062E3FC0,
  AijinChungongKingfisherImageResourceMetadataSlotOffset = 0x062E3FC8,
  AijinChungongKingfisherDownloadTaskMetadataSlotOffset = 0x062E3FD0,
};

__attribute__((noreturn, used, visibility("default")))
void AijinEnterGuestMainLoop(void) {
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_main_loop_enter");
  for (;;) {
    CFRunLoopRun();
  }
}

static BOOL AijinPopulateChungongCachedMetadataStub(
    uintptr_t stubOffset, uintptr_t slotOffset, uintptr_t metadata,
    const char *name, uintptr_t *targetOut) {
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (runtimeStart == 0 || metadata == 0) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT cached_metadata_stub_failed "
          "name=%s reason=missing_value runtime=%p metadata=%p",
          name, (void *)runtimeStart, (void *)metadata);
    return NO;
  }
  uintptr_t target = runtimeStart + stubOffset;
  uintptr_t slot = runtimeStart + slotOffset;
  memcpy((void *)slot, &metadata, sizeof(metadata));
  uintptr_t installed = 0;
  memcpy(&installed, (const void *)slot, sizeof(installed));
  if (installed != metadata) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT cached_metadata_stub_failed "
          "name=%s reason=slot_verify slot=%p expected=%p actual=%p",
          name, (void *)slot, (void *)metadata, (void *)installed);
    return NO;
  }
  if (targetOut != NULL) {
    *targetOut = target;
  }
  NSLog(@"AIJIN_CHUNGONG_COMPAT cached_metadata_stub_ready "
        "name=%s target=%p slot=%p metadata=%p",
        name, (void *)target, (void *)slot, (void *)metadata);
  return YES;
}

static BOOL AijinInstallChungongKingfisherWrapperMetadataCompatibility(
    void) {
  const struct mach_header_64 *header =
      AijinMappedGuestDylibHeaderWithSuffix(
          "Kingfisher.framework/Kingfisher");
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_failed "
          "reason=image_missing");
    return NO;
  }

  uintptr_t fieldAddress = (uintptr_t)header + 0x000B688C;
  int32_t relativeTarget = 0;
  memcpy(&relativeTarget, (const void *)fieldAddress, sizeof(relativeTarget));
  uintptr_t oldTarget = fieldAddress + (intptr_t)relativeTarget;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (oldTarget < runtimeStart || oldTarget >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)oldTarget);
    return NO;
  }

  AijinChungongKingfisherBase = (uintptr_t)header;
  AijinChungongKingfisherWrapperDescriptor =
      (const void *)((uintptr_t)header + 0x000B6880);
  AijinChungongSwiftGetGenericMetadata =
      (AijinSwiftGetGenericMetadataFunction)dlsym(
          RTLD_DEFAULT, "swift_getGenericMetadata");
  if (AijinChungongSwiftGetGenericMetadata == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_failed "
          "reason=generic_metadata_api");
    return NO;
  }

  typedef const void *(*SwiftGetObjCClassMetadataFunction)(Class);
  SwiftGetObjCClassMetadataFunction getObjCClassMetadata =
      (SwiftGetObjCClassMetadataFunction)dlsym(
          RTLD_DEFAULT, "swift_getObjCClassMetadata");
  const void *imageViewMetadata = getObjCClassMetadata == NULL
      ? NULL
      : getObjCClassMetadata([UIImageView class]);
  if (imageViewMetadata == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_failed "
          "reason=image_view_metadata");
    return NO;
  }
  const void *arguments[3] = {imageViewMetadata, NULL, NULL};
  AijinChungongMetadataResponse response =
      AijinChungongSwiftGetGenericMetadata(
          0xFF, arguments, AijinChungongKingfisherWrapperDescriptor);
  uintptr_t nativeTarget = 0;
  if (response.value == 0 ||
      !AijinPopulateChungongCachedMetadataStub(
          AijinChungongKingfisherWrapperMetadataStubOffset,
          AijinChungongKingfisherWrapperMetadataSlotOffset,
          response.value, "kingfisher_wrapper", &nativeTarget)) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_failed "
          "reason=metadata_prewarm value=%p state=%p",
          (void *)response.value, (void *)response.state);
    return NO;
  }
  intptr_t nativeDisplacement =
      (intptr_t)nativeTarget - (intptr_t)fieldAddress;
  if (nativeDisplacement < INT32_MIN || nativeDisplacement > INT32_MAX) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_failed "
          "reason=native_target_out_of_range target=%p",
          (void *)nativeTarget);
    return NO;
  }

  vm_address_t pageAddress = fieldAddress & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  int32_t replacement = (int32_t)nativeDisplacement;
  memcpy((void *)fieldAddress, &replacement, sizeof(replacement));
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_wrapper_patched "
        "field=%p old=%p native=%p descriptor=%p metadata=%p",
        (void *)fieldAddress, (void *)oldTarget, (void *)nativeTarget,
        AijinChungongKingfisherWrapperDescriptor, (void *)response.value);
  return YES;
}

static BOOL AijinInstallChungongKingfisherImageResourceMetadataCompatibility(
    void) {
  const struct mach_header_64 *header =
      AijinMappedGuestDylibHeaderWithSuffix(
          "Kingfisher.framework/Kingfisher");
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_image_resource_failed "
          "reason=image_missing");
    return NO;
  }

  // Kingfisher.KF.ImageResource's nominal descriptor is at 0xb701c. Its
  // metadata accessor at 0x95a34 is otherwise reached through an adversarys
  // thunk while Seal's viewDidLoad already owns a guest frame.
  uintptr_t fieldAddress = (uintptr_t)header + 0x000B7028;
  int32_t relativeTarget = 0;
  memcpy(&relativeTarget, (const void *)fieldAddress, sizeof(relativeTarget));
  uintptr_t oldTarget = fieldAddress + (intptr_t)relativeTarget;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (oldTarget < runtimeStart || oldTarget >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_image_resource_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)oldTarget);
    return NO;
  }

  AijinChungongKingfisherBase = (uintptr_t)header;
  AijinChungongKingfisherImageResourceDescriptor =
      (const void *)((uintptr_t)header + 0x000B701C);
  AijinChungongSwiftGetSingletonMetadata =
      (AijinSwiftGetSingletonMetadataFunction)dlsym(
          RTLD_DEFAULT, "swift_getSingletonMetadata");
  if (AijinChungongSwiftGetSingletonMetadata == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_image_resource_failed "
          "reason=singleton_metadata_api");
    return NO;
  }

  AijinChungongMetadataResponse response =
      AijinChungongSwiftGetSingletonMetadata(
          0xFF, AijinChungongKingfisherImageResourceDescriptor);
  uintptr_t nativeTarget = 0;
  if (response.value == 0 ||
      !AijinPopulateChungongCachedMetadataStub(
          AijinChungongKingfisherImageResourceMetadataStubOffset,
          AijinChungongKingfisherImageResourceMetadataSlotOffset,
          response.value, "kingfisher_image_resource", &nativeTarget)) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_image_resource_failed "
          "reason=metadata_prewarm value=%p state=%p",
          (void *)response.value, (void *)response.state);
    return NO;
  }
  intptr_t nativeDisplacement =
      (intptr_t)nativeTarget - (intptr_t)fieldAddress;
  if (nativeDisplacement < INT32_MIN || nativeDisplacement > INT32_MAX) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_image_resource_failed "
          "reason=native_target_out_of_range target=%p",
          (void *)nativeTarget);
    return NO;
  }

  vm_address_t pageAddress = fieldAddress & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_image_resource_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  int32_t replacement = (int32_t)nativeDisplacement;
  memcpy((void *)fieldAddress, &replacement, sizeof(replacement));
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_image_resource_patched "
        "field=%p old=%p native=%p descriptor=%p metadata=%p",
        (void *)fieldAddress, (void *)oldTarget, (void *)nativeTarget,
        AijinChungongKingfisherImageResourceDescriptor,
        (void *)response.value);
  return YES;
}

static BOOL AijinInstallChungongKingfisherDownloadTaskMetadataCompatibility(
    void) {
  const struct mach_header_64 *header =
      AijinMappedGuestDylibHeaderWithSuffix(
          "Kingfisher.framework/Kingfisher");
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_download_task_failed "
          "reason=image_missing");
    return NO;
  }

  // DownloadTask's nominal type descriptor is at VM 0xb5ce0. Its direct
  // metadata accessor at 0x41b30 only returns header+0xc8f68 and state zero.
  // Swift's mangled-type resolver reaches this field from inside translated
  // viewDidLoad; retaining the loader's guest thunk would recursively enter
  // adversarys. Point it at the equivalent native accessor instead.
  uintptr_t fieldAddress = (uintptr_t)header + 0x000B5CEC;
  int32_t relativeTarget = 0;
  memcpy(&relativeTarget, (const void *)fieldAddress, sizeof(relativeTarget));
  uintptr_t oldTarget = fieldAddress + (intptr_t)relativeTarget;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (oldTarget < runtimeStart || oldTarget >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_download_task_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)oldTarget);
    return NO;
  }

  AijinChungongKingfisherBase = (uintptr_t)header;
  uintptr_t metadata = AijinChungongKingfisherBase + 0x000C8F68;
  uintptr_t nativeTarget = 0;
  if (!AijinPopulateChungongCachedMetadataStub(
          AijinChungongKingfisherDownloadTaskMetadataStubOffset,
          AijinChungongKingfisherDownloadTaskMetadataSlotOffset,
          metadata, "kingfisher_download_task", &nativeTarget)) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_download_task_failed "
          "reason=metadata_stub");
    return NO;
  }
  intptr_t nativeDisplacement =
      (intptr_t)nativeTarget - (intptr_t)fieldAddress;
  if (nativeDisplacement < INT32_MIN || nativeDisplacement > INT32_MAX) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_download_task_failed "
          "reason=native_target_out_of_range target=%p",
          (void *)nativeTarget);
    return NO;
  }

  vm_address_t pageAddress = fieldAddress & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_download_task_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  int32_t replacement = (int32_t)nativeDisplacement;
  memcpy((void *)fieldAddress, &replacement, sizeof(replacement));
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT kingfisher_download_task_patched "
        "field=%p old=%p native=%p metadata=%p",
        (void *)fieldAddress, (void *)oldTarget, (void *)nativeTarget,
        (void *)metadata);
  return YES;
}

static Class AijinMappedChungongFullScreenControllerClass(void) {
  const struct mach_header_64 *header =
      AijinMappedChungongMainImageHeader();
  if (header == NULL) {
    return Nil;
  }
  // Seal's authenticated __objc_classlist places
  // _TtC4Seal22CLFullScreenController at VM 0x1010c3850. The translated
  // main image is mapped at its original 0x100000000-relative layout.
  return (__bridge Class)((void *)((uintptr_t)header + 0x010C3850));
}

static BOOL AijinPrewarmChungongUIViewControllerMetadata(void) {
  const struct mach_header_64 *header =
      AijinMappedChungongMainImageHeader();
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT metadata_prewarm_failed reason=image_missing");
    return NO;
  }

  // Seal's __swift5_typeref record at 0xEA587C is a relative reference to
  // the lazy UIViewController metadata accessor at guest PC 0xC7AC. The
  // NIVM loader rewrites that relative field to its native callback thunk.
  // Resolving it once while no guest frame is active prevents Swift from
  // entering the non-reentrant interpreter during AppDelegate startup.
  uintptr_t fieldAddress = (uintptr_t)header + 0x00EA587C;
  int32_t relativeTarget = 0;
  memcpy(&relativeTarget, (const void *)fieldAddress, sizeof(relativeTarget));
  uintptr_t targetAddress = fieldAddress + (intptr_t)relativeTarget;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  uintptr_t runtimeEnd = runtimeStart + 0x05000000;
  if (targetAddress < runtimeStart || targetAddress >= runtimeEnd) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT metadata_prewarm_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)targetAddress);
    return NO;
  }

  uintptr_t (*accessor)(uintptr_t, uintptr_t, uintptr_t) =
      (uintptr_t(*)(uintptr_t, uintptr_t, uintptr_t))(void *)targetAddress;
  NSLog(@"AIJIN_CHUNGONG_COMPAT metadata_prewarm_start field=%p target=%p",
        (void *)fieldAddress, (void *)targetAddress);
  uintptr_t value = accessor(0, 0, 0);
  if (value == 0) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT metadata_prewarm_failed reason=nil_result");
    return NO;
  }

  uintptr_t cachedReturnStub = runtimeStart + 0x0088B7C0;
  intptr_t nativeDisplacement =
      (intptr_t)cachedReturnStub - (intptr_t)fieldAddress;
  if (nativeDisplacement < INT32_MIN || nativeDisplacement > INT32_MAX) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT metadata_prewarm_failed "
          "reason=native_target_out_of_range target=%p",
          (void *)cachedReturnStub);
    return NO;
  }
  vm_address_t pageAddress = fieldAddress & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT metadata_prewarm_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  int32_t replacement = (int32_t)nativeDisplacement;
  memcpy((void *)fieldAddress, &replacement, sizeof(replacement));
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT metadata_prewarm_done value=%p native=%p",
        (void *)value, (void *)cachedReturnStub);
  return YES;
}

static BOOL AijinInstallChungongObjectMapperCompatibility(void) {
  const struct mach_header_64 *header =
      AijinMappedGuestDylibHeaderWithSuffix(
          "ObjectMapper.framework/ObjectMapper");
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_failed reason=image_missing");
    return NO;
  }
  // ObjectMapper __TEXT,__const+0x28f14 points to
  // Mapper.__deallocating_deinit (guest PC 0x14f98). The NIVM loader rewrites
  // it to an adversarys callback thunk, which is unsafe while Seal's guest
  // frame is active during didFinishLaunching.
  uintptr_t fieldAddress = (uintptr_t)header + 0x00028F14;
  int32_t relativeTarget = 0;
  memcpy(&relativeTarget, (const void *)fieldAddress, sizeof(relativeTarget));
  uintptr_t targetAddress = fieldAddress + (intptr_t)relativeTarget;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (targetAddress < runtimeStart ||
      targetAddress >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)targetAddress);
    return NO;
  }
  uintptr_t nativeStub = runtimeStart + 0x0088B7CC;
  intptr_t displacement = (intptr_t)nativeStub - (intptr_t)fieldAddress;
  if (displacement < INT32_MIN || displacement > INT32_MAX) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_failed "
          "reason=native_target_out_of_range target=%p",
          (void *)nativeStub);
    return NO;
  }
  vm_address_t pageAddress = fieldAddress & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  int32_t replacement = (int32_t)displacement;
  memcpy((void *)fieldAddress, &replacement, sizeof(replacement));
  // CodableTransform.__deallocating_deinit (guest PC 0x4694) is referenced
  // by two relative metadata fields on the same __DATA_CONST page.
  uintptr_t codableFields[] = {
      (uintptr_t)header + 0x000289B4,
      (uintptr_t)header + 0x00028C34,
  };
  uintptr_t codableOldTarget = 0;
  for (NSUInteger index = 0;
       index < sizeof(codableFields) / sizeof(codableFields[0]); index++) {
    int32_t oldRelative = 0;
    memcpy(&oldRelative, (const void *)codableFields[index],
           sizeof(oldRelative));
    uintptr_t oldTarget = codableFields[index] + (intptr_t)oldRelative;
    if (oldTarget < runtimeStart ||
        oldTarget >= runtimeStart + 0x05000000) {
      NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_failed "
            "reason=codable_target_invalid field=%p target=%p",
            (void *)codableFields[index], (void *)oldTarget);
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ);
      return NO;
    }
    intptr_t codableDisplacement =
        (intptr_t)nativeStub - (intptr_t)codableFields[index];
    int32_t codableReplacement = (int32_t)codableDisplacement;
    memcpy((void *)codableFields[index], &codableReplacement,
           sizeof(codableReplacement));
    codableOldTarget = oldTarget;
  }
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);

  // Map.__deallocating_deinit (guest PC 0xeda0) is stored as an authenticated
  // absolute callback in ObjectMapper __DATA+0x2d3c0. The loader materializes
  // it as another adversarys thunk rather than a signed relative field.
  uintptr_t mapDeallocField = (uintptr_t)header + 0x0002D3C0;
  uintptr_t mapDeallocTarget = 0;
  memcpy(&mapDeallocTarget, (const void *)mapDeallocField,
         sizeof(mapDeallocTarget));
  if (mapDeallocTarget < runtimeStart ||
      mapDeallocTarget >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_failed "
          "reason=map_target_invalid field=%p target=%p",
          (void *)mapDeallocField, (void *)mapDeallocTarget);
    return NO;
  }
  vm_address_t mapPage =
      mapDeallocField & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t mapProtection =
      vm_protect(mach_task_self(), mapPage, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (mapProtection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_failed "
          "reason=protect_map code=%d",
          mapProtection);
    return NO;
  }
  memcpy((void *)mapDeallocField, &nativeStub, sizeof(nativeStub));
  vm_protect(mach_task_self(), mapPage, vm_page_size, FALSE,
             VM_PROT_READ | VM_PROT_WRITE);
  NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_patched "
        "mapper_field=%p mapper_old=%p codable_old=%p map_field=%p "
        "map_old=%p native=%p",
        (void *)fieldAddress, (void *)targetAddress,
        (void *)codableOldTarget, (void *)mapDeallocField,
        (void *)mapDeallocTarget, (void *)nativeStub);
  return YES;
}

static BOOL AijinInstallChungongObjectMapperMetadataCompatibility(void) {
  const struct mach_header_64 *header =
      AijinMappedGuestDylibHeaderWithSuffix(
          "ObjectMapper.framework/ObjectMapper");
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_metadata_failed "
          "reason=image_missing");
    return NO;
  }

  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  uintptr_t allocationStub = runtimeStart + 0x0088B7E4;
  uintptr_t enumCompletionStub = runtimeStart + 0x0088B824;
  uintptr_t mapperCompletionStub = runtimeStart + 0x0088B874;
  uintptr_t allocationFields[] = {
      (uintptr_t)header + 0x000289A8,
      (uintptr_t)header + 0x00028C28,
      (uintptr_t)header + 0x00028F08,
      (uintptr_t)header + 0x00029058,
  };
  uintptr_t enumCompletionField = (uintptr_t)header + 0x00028C2C;
  uintptr_t mapperCompletionField = (uintptr_t)header + 0x00028F0C;

  vm_address_t pageAddress =
      allocationFields[0] & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_metadata_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }

  uintptr_t oldAllocation = 0;
  for (NSUInteger index = 0;
       index < sizeof(allocationFields) / sizeof(allocationFields[0]);
       index++) {
    int32_t oldRelative = 0;
    memcpy(&oldRelative, (const void *)allocationFields[index],
           sizeof(oldRelative));
    uintptr_t oldTarget =
        allocationFields[index] + (intptr_t)oldRelative;
    if (oldTarget < runtimeStart ||
        oldTarget >= runtimeStart + 0x05000000) {
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ);
      NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_metadata_failed "
            "reason=allocation_target_invalid field=%p target=%p",
            (void *)allocationFields[index], (void *)oldTarget);
      return NO;
    }
    intptr_t displacement =
        (intptr_t)allocationStub - (intptr_t)allocationFields[index];
    int32_t replacement = (int32_t)displacement;
    memcpy((void *)allocationFields[index], &replacement,
           sizeof(replacement));
    oldAllocation = oldTarget;
  }

  uintptr_t completionFields[] = {
      enumCompletionField,
      mapperCompletionField,
  };
  uintptr_t completionStubs[] = {
      enumCompletionStub,
      mapperCompletionStub,
  };
  uintptr_t oldCompletions[2] = {0};
  for (NSUInteger index = 0; index < 2; index++) {
    int32_t oldRelative = 0;
    memcpy(&oldRelative, (const void *)completionFields[index],
           sizeof(oldRelative));
    uintptr_t oldTarget =
        completionFields[index] + (intptr_t)oldRelative;
    if (oldTarget < runtimeStart ||
        oldTarget >= runtimeStart + 0x05000000) {
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ);
      NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_metadata_failed "
            "reason=completion_target_invalid field=%p target=%p",
            (void *)completionFields[index], (void *)oldTarget);
      return NO;
    }
    intptr_t displacement =
        (intptr_t)completionStubs[index] -
        (intptr_t)completionFields[index];
    int32_t replacement = (int32_t)displacement;
    memcpy((void *)completionFields[index], &replacement,
           sizeof(replacement));
    oldCompletions[index] = oldTarget;
  }
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT objectmapper_metadata_patched "
        "allocation_old=%p allocation_native=%p enum_old=%p enum_native=%p "
        "mapper_old=%p mapper_native=%p",
        (void *)oldAllocation, (void *)allocationStub,
        (void *)oldCompletions[0], (void *)enumCompletionStub,
        (void *)oldCompletions[1], (void *)mapperCompletionStub);
  return YES;
}

static BOOL AijinInstallChungongAppearanceEnumCompatibility(void) {
  const struct mach_header_64 *header =
      AijinMappedChungongMainImageHeader();
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT appearance_enum_failed "
          "reason=image_missing");
    return NO;
  }
  // Seal __const+0xd6d244 points to the String-to-appearance enum callback at
  // guest PC 0x239a6c. Native Swift calls it while didFinishLaunching still
  // owns the translated frame, so redirect it to a signed native byte writer.
  uintptr_t fieldAddress = (uintptr_t)header + 0x00D6D244;
  int32_t oldRelative = 0;
  memcpy(&oldRelative, (const void *)fieldAddress, sizeof(oldRelative));
  uintptr_t oldTarget = fieldAddress + (intptr_t)oldRelative;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (oldTarget < runtimeStart || oldTarget >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT appearance_enum_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)oldTarget);
    return NO;
  }
  uintptr_t nativeStub = runtimeStart + 0x0088B7D0;
  intptr_t displacement = (intptr_t)nativeStub - (intptr_t)fieldAddress;
  if (displacement < INT32_MIN || displacement > INT32_MAX) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT appearance_enum_failed "
          "reason=native_target_out_of_range target=%p",
          (void *)nativeStub);
    return NO;
  }
  vm_address_t pageAddress = fieldAddress & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT appearance_enum_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  int32_t replacement = (int32_t)displacement;
  memcpy((void *)fieldAddress, &replacement, sizeof(replacement));
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT appearance_enum_patched "
        "field=%p old=%p native=%p",
        (void *)fieldAddress, (void *)oldTarget, (void *)nativeStub);
  return YES;
}

static BOOL AijinPrewarmChungongModelWitness(void) {
  const struct mach_header_64 *header =
      AijinMappedChungongMainImageHeader();
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_witness_prewarm_failed "
          "reason=image_missing");
    return NO;
  }

  // Seal __swift5_proto+0xeab012 references the lazy witness accessor at
  // guest PC 0x239e78. During didFinishLaunching, Swift asks this accessor
  // to instantiate several ObjectMapper generic metadata records. Running
  // the same accessor before entering AppDelegate moves those native-to-guest
  // callbacks out of the long-lived translated launch frame.
  uintptr_t fieldAddress = (uintptr_t)header + 0x00EAB012;
  int32_t relativeTarget = 0;
  memcpy(&relativeTarget, (const void *)fieldAddress, sizeof(relativeTarget));
  uintptr_t targetAddress = fieldAddress + (intptr_t)relativeTarget;
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (targetAddress < runtimeStart ||
      targetAddress >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_witness_prewarm_failed "
          "reason=target_invalid field=%p target=%p",
          (void *)fieldAddress, (void *)targetAddress);
    return NO;
  }

  uintptr_t (*accessor)(uintptr_t, uintptr_t, uintptr_t) =
      (uintptr_t(*)(uintptr_t, uintptr_t, uintptr_t))(void *)targetAddress;
  NSLog(@"AIJIN_CHUNGONG_COMPAT model_witness_prewarm_start "
        "field=%p target=%p",
        (void *)fieldAddress, (void *)targetAddress);
  uintptr_t value = accessor(0, 0, 0);
  if (value == 0) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_witness_prewarm_failed "
          "reason=nil_result");
    return NO;
  }

  uintptr_t nativeStub = runtimeStart + 0x0088B7D8;
  intptr_t displacement =
      (intptr_t)nativeStub - (intptr_t)fieldAddress;
  if (displacement < INT32_MIN || displacement > INT32_MAX) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_witness_prewarm_failed "
          "reason=native_target_out_of_range target=%p",
          (void *)nativeStub);
    return NO;
  }
  vm_address_t pageAddress = fieldAddress & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_witness_prewarm_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  int32_t replacement = (int32_t)displacement;
  memcpy((void *)fieldAddress, &replacement, sizeof(replacement));
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT model_witness_prewarm_done "
        "value=%p native=%p",
        (void *)value, (void *)nativeStub);
  return YES;
}

typedef void *(*AijinSwiftBridgeObjectRetainFunction)(void *object);
typedef void (*AijinSwiftBridgeObjectReleaseFunction)(void *object);

static AijinSwiftBridgeObjectRetainFunction
    AijinChungongBridgeObjectRetain = NULL;
static AijinSwiftBridgeObjectReleaseFunction
    AijinChungongBridgeObjectRelease = NULL;

static void *AijinChungongModelCopyWitness(void *destination,
                                            const void *source) {
  memcpy(destination, source, 0xB1);
  const uintptr_t bridgeOffsets[] = {
      0x08, 0x18, 0x28, 0x38, 0x48, 0x58,
      0x68, 0x78, 0x88, 0x98, 0xA8,
  };
  for (NSUInteger index = 0;
       index < sizeof(bridgeOffsets) / sizeof(bridgeOffsets[0]); index++) {
    void *object = NULL;
    memcpy(&object, (const uint8_t *)destination + bridgeOffsets[index],
           sizeof(object));
    AijinChungongBridgeObjectRetain(object);
  }
  return destination;
}

static void AijinChungongModelDestroyWitness(void *value) {
  const uintptr_t bridgeOffsets[] = {
      0x08, 0x18, 0x28, 0x38, 0x48, 0x58,
      0x68, 0x78, 0x88, 0x98, 0xA8,
  };
  for (NSUInteger index = 0;
       index < sizeof(bridgeOffsets) / sizeof(bridgeOffsets[0]); index++) {
    void *object = NULL;
    memcpy(&object, (const uint8_t *)value + bridgeOffsets[index],
           sizeof(object));
    AijinChungongBridgeObjectRelease(object);
  }
}

static BOOL AijinInstallChungongModelValueWitnessCompatibility(void) {
  const struct mach_header_64 *header =
      AijinMappedChungongMainImageHeader();
  if (header == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_value_witness_failed "
          "reason=image_missing");
    return NO;
  }
  AijinChungongBridgeObjectRetain =
      (AijinSwiftBridgeObjectRetainFunction)dlsym(
          RTLD_DEFAULT, "swift_bridgeObjectRetain");
  AijinChungongBridgeObjectRelease =
      (AijinSwiftBridgeObjectReleaseFunction)dlsym(
          RTLD_DEFAULT, "swift_bridgeObjectRelease");
  if (AijinChungongBridgeObjectRetain == NULL ||
      AijinChungongBridgeObjectRelease == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_value_witness_failed "
          "reason=swift_runtime_symbols");
    return NO;
  }

  // Seal's value-witness table at 0xfc0b10 contains the destroy and copy
  // callbacks for a 0xb1-byte value made of eleven Swift bridge objects.
  // The implementations above are instruction-for-instruction equivalent to
  // guest PCs 0x239454 and 0x2394c4, but execute as signed host code.
  uintptr_t destroyField = (uintptr_t)header + 0x00FC0B10;
  uintptr_t copyField = (uintptr_t)header + 0x00FC0B18;
  uintptr_t oldDestroy = 0;
  uintptr_t oldCopy = 0;
  memcpy(&oldDestroy, (const void *)destroyField, sizeof(oldDestroy));
  memcpy(&oldCopy, (const void *)copyField, sizeof(oldCopy));
  uintptr_t runtimeStart = AijinDiagnosticAdversarysBase;
  if (oldDestroy < runtimeStart || oldDestroy >= runtimeStart + 0x05000000 ||
      oldCopy < runtimeStart || oldCopy >= runtimeStart + 0x05000000) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_value_witness_failed "
          "reason=target_invalid destroy=%p copy=%p",
          (void *)oldDestroy, (void *)oldCopy);
    return NO;
  }
  vm_address_t pageAddress = destroyField & ~(vm_address_t)(vm_page_size - 1);
  kern_return_t protection =
      vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE,
                 VM_PROT_READ | VM_PROT_WRITE);
  if (protection != KERN_SUCCESS) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT model_value_witness_failed "
          "reason=protect_write code=%d",
          protection);
    return NO;
  }
  uintptr_t nativeDestroy =
      (uintptr_t)(void *)&AijinChungongModelDestroyWitness;
  uintptr_t nativeCopy = (uintptr_t)(void *)&AijinChungongModelCopyWitness;
  memcpy((void *)destroyField, &nativeDestroy, sizeof(nativeDestroy));
  memcpy((void *)copyField, &nativeCopy, sizeof(nativeCopy));
  vm_protect(mach_task_self(), pageAddress, vm_page_size, FALSE, VM_PROT_READ);
  NSLog(@"AIJIN_CHUNGONG_COMPAT model_value_witness_patched "
        "destroy_old=%p destroy_native=%p copy_old=%p copy_native=%p",
        (void *)oldDestroy, (void *)nativeDestroy,
        (void *)oldCopy, (void *)nativeCopy);
  return YES;
}

static void AijinChungongLaunchPreparationViewDidLoad(id controller,
                                                        SEL selector) {
  (void)selector;
  NSLog(@"AIJIN_CHUNGONG_COMPAT native_launch_view_did_load_begin");

  UIViewController *viewController = (UIViewController *)controller;
  UIView *view = viewController.view;
  view.backgroundColor = UIColor.blackColor;
  if ([view viewWithTag:0x41504258] == nil) {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
    imageView.tag = 0x41504258;
    imageView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = [UIImage imageNamed:@"ic_welcome_m"
                                 inBundle:AijinGuestMainBundle
            compatibleWithTraitCollection:nil];
    [view addSubview:imageView];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    indicator.color = UIColor.whiteColor;
    [indicator startAnimating];
    [view addSubview:indicator];
    [NSLayoutConstraint activateConstraints:@[
      [indicator.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
      [indicator.bottomAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide
                                                   .bottomAnchor
                                              constant:-36.0],
    ]];
  }
  NSLog(@"AIJIN_CHUNGONG_COMPAT native_launch_view_loaded image=%d",
        [UIImage imageNamed:@"ic_welcome_m"
                   inBundle:AijinGuestMainBundle
          compatibleWithTraitCollection:nil] != nil);
}

static void AijinChungongLaunchPreparationLoadView(id controller,
                                                     SEL selector) {
  (void)selector;
  NSLog(@"AIJIN_CHUNGONG_COMPAT native_launch_load_view_begin");
  CGRect bounds = UIScreen.mainScreen.bounds;
  UIView *view = [[UIView alloc] initWithFrame:bounds];
  view.backgroundColor = UIColor.blackColor;
  ((UIViewController *)controller).view = view;
  NSLog(@"AIJIN_CHUNGONG_COMPAT native_launch_load_view_end");
}

static void AijinInstallChungongLaunchControllerCompatibility(void) {
  Class controllerClass =
      NSClassFromString(@"Seal.LaunchPreparationViewController");
  if (controllerClass == Nil) {
    controllerClass =
        objc_getClass("_TtC4Seal31LaunchPreparationViewController");
  }
  const char *className = controllerClass == Nil
      ? NULL
      : class_getName(controllerClass);
  if (className == NULL ||
      (strcmp(className, "Seal.LaunchPreparationViewController") != 0 &&
       strcmp(className,
              "_TtC4Seal31LaunchPreparationViewController") != 0)) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT launch_controller_missing");
    return;
  }
  SEL selector = @selector(viewDidLoad);
  Method method = class_getInstanceMethod(controllerClass, selector);
  if (method == NULL) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT launch_view_method_missing");
    return;
  }
  class_replaceMethod(
      controllerClass, selector,
      (IMP)AijinChungongLaunchPreparationViewDidLoad,
      method_getTypeEncoding(method));
  SEL loadViewSelector = @selector(loadView);
  Method loadViewMethod = class_getInstanceMethod(
      class_getSuperclass(controllerClass), loadViewSelector);
  if (loadViewMethod != NULL) {
    class_replaceMethod(
        controllerClass, loadViewSelector,
        (IMP)AijinChungongLaunchPreparationLoadView,
        method_getTypeEncoding(loadViewMethod));
  }
  NSLog(@"AIJIN_CHUNGONG_COMPAT launch_view_patched class=%s load_view=%d",
        className, loadViewMethod != NULL);
}

static void AijinInstallChungongUIKitCompatibility(void) {
  Class registeredClass = NSClassFromString(@"Seal.CLFullScreenController");
  if (registeredClass == Nil) {
    registeredClass = objc_getClass("_TtC4Seal22CLFullScreenController");
  }
  Class mappedClass = AijinMappedChungongFullScreenControllerClass();
  Class controllerClasses[] = {registeredClass, mappedClass};
  NSUInteger matched = 0;
  NSUInteger replaced = 0;
  for (NSUInteger classIndex = 0;
       classIndex < sizeof(controllerClasses) / sizeof(controllerClasses[0]);
       classIndex += 1) {
    Class controllerClass = controllerClasses[classIndex];
    if (controllerClass == Nil ||
        (classIndex > 0 && controllerClass == controllerClasses[0])) {
      continue;
    }
    const char *className = class_getName(controllerClass);
    if (className == NULL ||
        (strcmp(className, "Seal.CLFullScreenController") != 0 &&
         strcmp(className, "_TtC4Seal22CLFullScreenController") != 0)) {
      NSLog(@"AIJIN_CHUNGONG_COMPAT candidate_rejected pointer=%p name=%s",
            controllerClass, className ?: "unknown");
      continue;
    }
    Class superclass = class_getSuperclass(controllerClass);
    if (superclass == Nil) {
      continue;
    }
    matched += 1;

    // These five Swift overrides contain only an objc_msgSendSuper2
    // forwarder. UIKit can invoke them reentrantly while the translated
    // AppDelegate is still inside didFinishLaunching. Use the equivalent
    // native superclass implementations so this no-op path does not open a
    // nested interpreter.
    NSUInteger classReplaced = 0;
    for (NSString *selectorName in
         @[@"viewWillAppear:", @"viewDidAppear:",
           @"viewWillDisappear:", @"viewDidDisappear:",
           @"viewDidLayoutSubviews"]) {
      SEL selector = NSSelectorFromString(selectorName);
      Method method = class_getInstanceMethod(superclass, selector);
      if (method == NULL) {
        continue;
      }
      class_replaceMethod(controllerClass, selector,
                          method_getImplementation(method),
                          method_getTypeEncoding(method));
      classReplaced += 1;
      replaced += 1;
    }
    NSLog(@"AIJIN_CHUNGONG_COMPAT class_patched pointer=%p name=%s "
          "superclass=%@ methods=%lu",
          controllerClass, className, NSStringFromClass(superclass),
          (unsigned long)classReplaced);
  }
  if (matched == 0) {
    NSLog(@"AIJIN_CHUNGONG_COMPAT install_failed reason=controller_missing");
    return;
  }
  NSLog(@"AIJIN_CHUNGONG_COMPAT installed classes=%lu methods=%lu",
        (unsigned long)matched, (unsigned long)replaced);
  AijinInstallChungongLaunchControllerCompatibility();
}

static IMP AijinOriginalMakeKeyAndVisible = NULL;
static IMP AijinOriginalSetRootViewController = NULL;
static BOOL AijinDeferGuestWindowVisibility = NO;
static UIWindow *AijinDeferredGuestRootWindow = nil;
static UIViewController *AijinDeferredGuestRootController = nil;

static UIWindow *AijinCurrentForegroundWindow(UIApplication *application) {
  UIWindow *visibleWindow = nil;
  for (UIScene *scene in application.connectedScenes) {
    if (![scene isKindOfClass:UIWindowScene.class]) {
      continue;
    }
    for (UIWindow *window in ((UIWindowScene *)scene).windows) {
      if (window.isKeyWindow) {
        return window;
      }
      if (visibleWindow == nil && !window.hidden && window.alpha > 0) {
        visibleWindow = window;
      }
    }
  }
  return visibleWindow ?: application.windows.firstObject;
}

static void AijinSendGuestLifecycle(id guestDelegate, SEL selector,
                                     NSString *source) {
  if (guestDelegate == nil ||
      ![guestDelegate respondsToSelector:selector]) {
    return;
  }
  NSLog(@"AIJIN_PLAYBOX_RUNTIME lifecycle_forward source=%@ delegate=%@ "
         "selector=%@",
        source, NSStringFromClass([guestDelegate class]),
        NSStringFromSelector(selector));
  ((void (*)(id, SEL, id))objc_msgSend)(
      guestDelegate, selector, UIApplication.sharedApplication);
}

static void AijinResetInProcessGuestLifecycle(void) {
  AijinInProcessGuestLifecycleReady = NO;
  AijinInProcessGuestLifecycleState =
      AijinGuestLifecycleStateUnavailable;
}

static void AijinMarkInProcessGuestLifecycleActive(void) {
  AijinInProcessGuestLifecycleState = AijinGuestLifecycleStateActive;
  AijinInProcessGuestLifecycleReady =
      AijinInProcessGuestDelegate != nil &&
      __atomic_load_n(&AijinGuestRuntimeLaunchClaim,
                      __ATOMIC_SEQ_CST) != 0;
  NSLog(@"AIJIN_PLAYBOX_RUNTIME lifecycle_ready ready=%d delegate=%@",
        AijinInProcessGuestLifecycleReady,
        NSStringFromClass([AijinInProcessGuestDelegate class]));
}

// Called synchronously by AijinSceneDelegate. Values are intentionally a
// small C ABI so the Swift scene delegate does not need Objective-C runtime
// knowledge about the selected guest.
void AijinForwardInProcessGuestLifecycle(int32_t event) {
  if (!AijinInProcessGuestLifecycleReady ||
      AijinInProcessGuestDelegate == nil ||
      __atomic_load_n(&AijinGuestRuntimeLaunchClaim,
                      __ATOMIC_SEQ_CST) == 0) {
    return;
  }

  switch (event) {
    case 1:  // sceneWillResignActive
      if (AijinInProcessGuestLifecycleState !=
          AijinGuestLifecycleStateActive) {
        return;
      }
      AijinInProcessGuestLifecycleState =
          AijinGuestLifecycleStateInactive;
      AijinSendGuestLifecycle(
          AijinInProcessGuestDelegate,
          @selector(applicationWillResignActive:), @"host_scene");
      break;
    case 2:  // sceneDidEnterBackground
      if (AijinInProcessGuestLifecycleState ==
          AijinGuestLifecycleStateBackground) {
        return;
      }
      AijinInProcessGuestLifecycleState =
          AijinGuestLifecycleStateBackground;
      AijinSendGuestLifecycle(
          AijinInProcessGuestDelegate,
          @selector(applicationDidEnterBackground:), @"host_scene");
      break;
    case 3:  // sceneWillEnterForeground
      if (AijinInProcessGuestLifecycleState !=
          AijinGuestLifecycleStateBackground) {
        return;
      }
      AijinInProcessGuestLifecycleState =
          AijinGuestLifecycleStateInactive;
      AijinSendGuestLifecycle(
          AijinInProcessGuestDelegate,
          @selector(applicationWillEnterForeground:), @"host_scene");
      break;
    case 4:  // sceneDidBecomeActive
      if (AijinInProcessGuestLifecycleState ==
          AijinGuestLifecycleStateActive) {
        return;
      }
      AijinInProcessGuestLifecycleState = AijinGuestLifecycleStateActive;
      AijinSendGuestLifecycle(
          AijinInProcessGuestDelegate,
          @selector(applicationDidBecomeActive:), @"host_scene");
      break;
    default:
      break;
  }
}

// HBuilder guests were built before scene adoption became mandatory.  When
// their real `main` enters UIApplicationMain on iOS 27, UIKit now terminates
// the process unless the active main bundle declares a scene delegate.  This
// Objective-C class is deliberately module-independent so it can be resolved
// while NSBundle.mainBundle is redirected to the extracted guest bundle.
@interface AijinGuestSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, assign) AijinGuestLifecycleState lifecycleState;
@end

@implementation AijinGuestSceneDelegate
- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
               options:(UISceneConnectionOptions *)connectionOptions {
  (void)session;
  (void)connectionOptions;
  if (![scene isKindOfClass:UIWindowScene.class]) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_scene_failed reason=not_window_scene");
    return;
  }

  id guestDelegate = UIApplication.sharedApplication.delegate;
  UIWindow *guestWindow = nil;
  if ([guestDelegate respondsToSelector:@selector(window)]) {
    guestWindow = ((id (*)(id, SEL))objc_msgSend)(guestDelegate,
                                                  @selector(window));
  }
  if (guestWindow == nil) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_scene_failed reason=window_missing "
           "delegate=%@",
          NSStringFromClass([guestDelegate class]));
    return;
  }

  UIWindowScene *windowScene = (UIWindowScene *)scene;
  if (guestWindow.windowScene != windowScene) {
    guestWindow.windowScene = windowScene;
  }
  self.window = guestWindow;
  AijinInstallGuestFloatingControl(guestWindow);
  // DCloud completes its initial activation as part of the legacy app
  // bootstrap. Re-sending applicationDidBecomeActive here can trigger its
  // one-time restart path, so treat the connected foreground scene as active
  // and only bridge subsequent background/foreground transitions.
  self.lifecycleState = AijinGuestLifecycleStateActive;
  [guestWindow makeKeyAndVisible];
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_scene_connected delegate=%@ window=%@ "
         "root=%@ scene=%@",
        NSStringFromClass([guestDelegate class]),
        NSStringFromClass(guestWindow.class),
        NSStringFromClass(guestWindow.rootViewController.class),
        windowScene.session.persistentIdentifier);
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
  (void)scene;
  if (self.lifecycleState == AijinGuestLifecycleStateActive) {
    return;
  }
  self.lifecycleState = AijinGuestLifecycleStateActive;
  AijinSendGuestLifecycle(
      UIApplication.sharedApplication.delegate,
      @selector(applicationDidBecomeActive:), @"guest_scene");
}

- (void)sceneWillResignActive:(UIScene *)scene {
  (void)scene;
  if (self.lifecycleState != AijinGuestLifecycleStateActive) {
    return;
  }
  self.lifecycleState = AijinGuestLifecycleStateInactive;
  AijinSendGuestLifecycle(
      UIApplication.sharedApplication.delegate,
      @selector(applicationWillResignActive:), @"guest_scene");
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
  (void)scene;
  if (self.lifecycleState == AijinGuestLifecycleStateBackground) {
    return;
  }
  self.lifecycleState = AijinGuestLifecycleStateBackground;
  AijinSendGuestLifecycle(
      UIApplication.sharedApplication.delegate,
      @selector(applicationDidEnterBackground:), @"guest_scene");
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
  (void)scene;
  if (self.lifecycleState != AijinGuestLifecycleStateBackground) {
    return;
  }
  self.lifecycleState = AijinGuestLifecycleStateInactive;
  AijinSendGuestLifecycle(
      UIApplication.sharedApplication.delegate,
      @selector(applicationWillEnterForeground:), @"guest_scene");
}
@end

#if defined(AIJIN_HBUILDER_DIAGNOSTICS)
static void AijinLogGuestControllerTree(UIViewController *controller,
                                         NSUInteger depth) {
  if (controller == nil || depth > 8) {
    return;
  }
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC controller depth=%lu class=%@ view=%@ "
         "children=%lu presented=%@",
        (unsigned long)depth, NSStringFromClass(controller.class),
        NSStringFromClass(controller.view.class),
        (unsigned long)controller.childViewControllers.count,
        NSStringFromClass(controller.presentedViewController.class));
  for (UIViewController *child in controller.childViewControllers) {
    AijinLogGuestControllerTree(child, depth + 1);
  }
  if (controller.presentedViewController != nil) {
    AijinLogGuestControllerTree(controller.presentedViewController,
                                 depth + 1);
  }
}

static void AijinLogGuestViewTree(UIView *view, NSUInteger depth,
                                   NSUInteger *visited) {
  if (view == nil || depth > 12 || *visited >= 240) {
    return;
  }
  *visited += 1;
  NSString *className = NSStringFromClass(view.class);
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC view depth=%lu class=%@ frame=%@ "
         "hidden=%d alpha=%.3f subviews=%lu",
        (unsigned long)depth, className, NSStringFromCGRect(view.frame),
        view.hidden, view.alpha, (unsigned long)view.subviews.count);

  if ([className containsString:@"WKWebView"]) {
    id URL = nil;
    BOOL loading = NO;
    double progress = 0;
    SEL URLSelector = NSSelectorFromString(@"URL");
    SEL loadingSelector = NSSelectorFromString(@"isLoading");
    SEL progressSelector = NSSelectorFromString(@"estimatedProgress");
    if ([view respondsToSelector:URLSelector]) {
      URL = ((id (*)(id, SEL))objc_msgSend)(view, URLSelector);
    }
    if ([view respondsToSelector:loadingSelector]) {
      loading = ((BOOL (*)(id, SEL))objc_msgSend)(view, loadingSelector);
    }
    if ([view respondsToSelector:progressSelector]) {
      progress = ((double (*)(id, SEL))objc_msgSend)(view,
                                                     progressSelector);
    }
    NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC webview url=%@ loading=%d "
           "progress=%.3f",
          URL, loading, progress);
    SEL evaluateSelector =
        NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
    if ([view respondsToSelector:evaluateSelector]) {
      void (^completion)(id, NSError *) = ^(id result, NSError *error) {
        NSString *text = result == nil ? @"" : [result description];
        if (text.length > 3000) {
          text = [text substringToIndex:3000];
        }
        NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC document error=%@ text=%@",
              error.localizedDescription ?: @"none", text);
      };
      ((void (*)(id, SEL, id, id))objc_msgSend)(
          view, evaluateSelector,
          @"JSON.stringify({title:document.title,body:document.body&&"
           "document.body.innerText,html:document.documentElement&&"
           "document.documentElement.outerHTML})",
          completion);
    }
  }
  for (UIView *subview in view.subviews) {
    AijinLogGuestViewTree(subview, depth + 1, visited);
  }
}

static void AijinLogHBuilderSurface(NSString *stage) {
  UIApplication *application = UIApplication.sharedApplication;
  UIWindow *window = AijinCurrentForegroundWindow(application);
  NSUInteger visited = 0;
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC surface stage=%@ delegate=%@ window=%@ "
         "root=%@ scene=%@",
        stage, NSStringFromClass(application.delegate.class),
        NSStringFromClass(window.class),
        NSStringFromClass(window.rootViewController.class),
        window.windowScene.session.persistentIdentifier);
  AijinLogGuestControllerTree(window.rootViewController, 0);
  AijinLogGuestViewTree(window, 0, &visited);
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC surface_end stage=%@ views=%lu",
        stage, (unsigned long)visited);
}

static void AijinLogObjectiveCClassMethods(NSString *className) {
  Class runtimeClass = NSClassFromString(className);
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC class name=%@ pointer=%p image=%s",
        className, runtimeClass,
        runtimeClass == Nil ? "missing" : (class_getImageName(runtimeClass) ?: "unknown"));
  if (runtimeClass == Nil) {
    return;
  }
  unsigned int methodCount = 0;
  Method *methods = class_copyMethodList(runtimeClass, &methodCount);
  for (unsigned int index = 0; index < methodCount; index += 1) {
    NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC method class=%@ selector=%@ types=%s",
          className, NSStringFromSelector(method_getName(methods[index])),
          method_getTypeEncoding(methods[index]) ?: "unknown");
  }
  free(methods);
}

static IMP AijinOriginalWKLoadRequest = NULL;
static IMP AijinOriginalWKLoadFileURL = NULL;
static IMP AijinOriginalWKLoadHTMLString = NULL;

static id AijinDiagnosticWKLoadRequest(id webView, SEL selector,
                                        NSURLRequest *request) {
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC wk_load_request url=%@ main=%@",
        request.URL, request.mainDocumentURL);
  return AijinOriginalWKLoadRequest == NULL
      ? nil
      : ((id (*)(id, SEL, id))AijinOriginalWKLoadRequest)(webView, selector,
                                                            request);
}

static id AijinDiagnosticWKLoadFileURL(id webView, SEL selector,
                                        NSURL *URL, NSURL *readAccessURL) {
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC wk_load_file url=%@ read_access=%@",
        URL, readAccessURL);
  return AijinOriginalWKLoadFileURL == NULL
      ? nil
      : ((id (*)(id, SEL, id, id))AijinOriginalWKLoadFileURL)(
            webView, selector, URL, readAccessURL);
}

static id AijinDiagnosticWKLoadHTMLString(id webView, SEL selector,
                                           NSString *string,
                                           NSURL *baseURL) {
  NSString *preview = string ?: @"";
  if (preview.length > 240) {
    preview = [preview substringToIndex:240];
  }
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC wk_load_html base=%@ html=%@",
        baseURL, preview);
  return AijinOriginalWKLoadHTMLString == NULL
      ? nil
      : ((id (*)(id, SEL, id, id))AijinOriginalWKLoadHTMLString)(
            webView, selector, string, baseURL);
}

static void AijinInstallWKWebViewLoadDiagnostics(void) {
  Class webViewClass = NSClassFromString(@"WKWebView");
  if (webViewClass == Nil) {
    NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC wk_hook_failed reason=class_missing");
    return;
  }
  Method requestMethod = class_getInstanceMethod(
      webViewClass, NSSelectorFromString(@"loadRequest:"));
  Method fileMethod = class_getInstanceMethod(
      webViewClass,
      NSSelectorFromString(@"loadFileURL:allowingReadAccessToURL:"));
  Method htmlMethod = class_getInstanceMethod(
      webViewClass, NSSelectorFromString(@"loadHTMLString:baseURL:"));
  if (requestMethod != NULL && AijinOriginalWKLoadRequest == NULL) {
    AijinOriginalWKLoadRequest = method_setImplementation(
        requestMethod, (IMP)AijinDiagnosticWKLoadRequest);
  }
  if (fileMethod != NULL && AijinOriginalWKLoadFileURL == NULL) {
    AijinOriginalWKLoadFileURL = method_setImplementation(
        fileMethod, (IMP)AijinDiagnosticWKLoadFileURL);
  }
  if (htmlMethod != NULL && AijinOriginalWKLoadHTMLString == NULL) {
    AijinOriginalWKLoadHTMLString = method_setImplementation(
        htmlMethod, (IMP)AijinDiagnosticWKLoadHTMLString);
  }
  NSLog(@"AIJIN_HBUILDER_DIAGNOSTIC wk_hook_ready request=%d file=%d html=%d",
        AijinOriginalWKLoadRequest != NULL,
        AijinOriginalWKLoadFileURL != NULL,
        AijinOriginalWKLoadHTMLString != NULL);
}

static void AijinInstallHBuilderDiagnostics(void) {
  AijinInstallWKWebViewLoadDiagnostics();
  for (NSString *className in @[
         @"AppDelegate", @"PDRCore", @"SnKiwiModule", @"SnYxdModule",
         @"SnChengziModule", @"SnChengziProxy", @"Kiwi",
         @"WRSHttpServerPlugins"
       ]) {
    AijinLogObjectiveCClassMethods(className);
  }
  for (NSNumber *delay in @[@5, @15, @30]) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 delay.integerValue * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
      AijinLogHBuilderSurface(
          [NSString stringWithFormat:@"%lds", (long)delay.integerValue]);
    });
  }
}
#endif

static void AijinGuestAwareMakeKeyAndVisible(UIWindow *window, SEL selector) {
  if (AijinDeferGuestWindowVisibility) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME window_visibility_deferred class=%@",
          NSStringFromClass(window.class));
    return;
  }
  if (AijinOriginalMakeKeyAndVisible != NULL) {
    ((void (*)(id, SEL))AijinOriginalMakeKeyAndVisible)(window, selector);
  }
}

static void AijinGuestAwareSetRootViewController(
    UIWindow *window, SEL selector, UIViewController *controller) {
  if (AijinDeferGuestWindowVisibility) {
    AijinDeferredGuestRootWindow = window;
    AijinDeferredGuestRootController = controller;
    NSLog(@"AIJIN_PLAYBOX_RUNTIME root_controller_deferred window=%@ root=%@",
          NSStringFromClass(window.class),
          NSStringFromClass(controller.class));
    return;
  }
  if (AijinOriginalSetRootViewController != NULL) {
    ((void (*)(id, SEL, id))AijinOriginalSetRootViewController)(
        window, selector, controller);
  }
}

static BOOL AijinBeginGuestWindowVisibilityDeferral(void) {
  Method visibilityMethod = class_getInstanceMethod(
      UIWindow.class, @selector(makeKeyAndVisible));
  Method rootControllerMethod = class_getInstanceMethod(
      UIWindow.class, @selector(setRootViewController:));
  if (visibilityMethod == NULL || rootControllerMethod == NULL) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME window_visibility_deferral_failed");
    return NO;
  }
  if (AijinOriginalMakeKeyAndVisible == NULL) {
    AijinOriginalMakeKeyAndVisible = method_setImplementation(
        visibilityMethod, (IMP)AijinGuestAwareMakeKeyAndVisible);
  }
  if (AijinOriginalSetRootViewController == NULL) {
    AijinOriginalSetRootViewController = method_setImplementation(
        rootControllerMethod, (IMP)AijinGuestAwareSetRootViewController);
  }
  AijinDeferredGuestRootWindow = nil;
  AijinDeferredGuestRootController = nil;
  AijinDeferGuestWindowVisibility = YES;
  return YES;
}

static void AijinEndGuestWindowVisibilityDeferral(BOOL installed,
                                                   BOOL applyImmediately) {
  if (installed) {
    AijinDeferGuestWindowVisibility = NO;
    if (!applyImmediately) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME root_controller_apply_deferred");
      return;
    }
    UIWindow *window = AijinDeferredGuestRootWindow;
    UIViewController *controller = AijinDeferredGuestRootController;
    AijinDeferredGuestRootWindow = nil;
    AijinDeferredGuestRootController = nil;
    if (window != nil && AijinOriginalSetRootViewController != NULL) {
      ((void (*)(id, SEL, id))AijinOriginalSetRootViewController)(
          window, @selector(setRootViewController:), controller);
      NSLog(@"AIJIN_PLAYBOX_RUNTIME root_controller_applied window=%@ root=%@",
            NSStringFromClass(window.class),
            NSStringFromClass(controller.class));
    }
  }
}

static void AijinApplyDeferredGuestRootControllerToWindow(
    UIWindow *destinationWindow) {
  UIWindow *guestWindow = AijinDeferredGuestRootWindow;
  UIViewController *controller = AijinDeferredGuestRootController;
  AijinDeferredGuestRootWindow = nil;
  AijinDeferredGuestRootController = nil;
  UIWindow *window = destinationWindow ?: guestWindow;
  if (window == nil || controller == nil ||
      AijinOriginalSetRootViewController == NULL) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME root_controller_apply_skipped guest=%@ "
          "destination=%@ root=%@",
          NSStringFromClass(guestWindow.class),
          NSStringFromClass(destinationWindow.class),
          NSStringFromClass(controller.class));
    return;
  }
  NSLog(@"AIJIN_PLAYBOX_RUNTIME root_controller_apply_begin guest=%@ "
        "destination=%@ root=%@",
        NSStringFromClass(guestWindow.class), NSStringFromClass(window.class),
        NSStringFromClass(controller.class));
  ((void (*)(id, SEL, id))AijinOriginalSetRootViewController)(
      window, @selector(setRootViewController:), controller);
  NSLog(@"AIJIN_PLAYBOX_RUNTIME root_controller_applied window=%@ root=%@",
        NSStringFromClass(window.class), NSStringFromClass(controller.class));
}

static UIViewController *AijinTakeDeferredGuestRootController(
    UIWindow **guestWindowOut) {
  UIWindow *guestWindow = AijinDeferredGuestRootWindow;
  UIViewController *controller = AijinDeferredGuestRootController;
  AijinDeferredGuestRootWindow = nil;
  AijinDeferredGuestRootController = nil;
  if (guestWindowOut != NULL) {
    *guestWindowOut = guestWindow;
  }
  return controller;
}

static void AijinCancelGuestWindowVisibilityDeferral(void) {
  AijinDeferGuestWindowVisibility = NO;
  AijinDeferredGuestRootWindow = nil;
  AijinDeferredGuestRootController = nil;
}

typedef void (*AijinTerminateHandlerFunction)(void);
typedef AijinTerminateHandlerFunction (*AijinSetTerminateFunction)(
    AijinTerminateHandlerFunction);

static void AijinDiagnosticTerminateHandler(void) {
  void *frames[96] = {0};
  int count = backtrace(frames, (int)(sizeof(frames) / sizeof(frames[0])));
  dprintf(STDERR_FILENO, "AIJIN_DIAGNOSTIC_TERMINATE frames=%d\n", count);
  backtrace_symbols_fd(frames, count, STDERR_FILENO);
  _exit(199);
}

static void AijinInstallDiagnosticTerminateHandler(void) {
  AijinSetTerminateFunction setTerminate =
      (AijinSetTerminateFunction)dlsym(RTLD_DEFAULT,
                                        "_ZSt13set_terminatePFvvE");
  if (setTerminate == NULL) {
    NSLog(@"AIJIN_DIAGNOSTIC_TERMINATE install_failed error=%s", dlerror());
    return;
  }
  setTerminate(AijinDiagnosticTerminateHandler);
  NSLog(@"AIJIN_DIAGNOSTIC_TERMINATE installed");
}

static BOOL AijinPreloadLooseGuestImages(NSString *bundlePath) {
  NSString *manifestPath =
      [bundlePath stringByAppendingPathComponent:@"TempMailLooseImages.plist"];
  NSArray *images = [NSArray arrayWithContentsOfFile:manifestPath];
  if (images == nil) {
    return YES;
  }
  NSString *bundleRoot = bundlePath.stringByStandardizingPath;
  AijinLooseGuestImages = [NSMutableArray arrayWithCapacity:images.count];
  for (id candidate in images) {
    if (![candidate isKindOfClass:NSString.class] ||
        [candidate hasPrefix:@"/"]) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME loose_preload_failed reason=bad_path");
      return NO;
    }
    NSString *imagePath =
        [bundlePath stringByAppendingPathComponent:candidate];
    NSString *standardized = imagePath.stringByStandardizingPath;
    NSString *requiredPrefix = [bundleRoot stringByAppendingString:@"/"];
    if (![standardized hasPrefix:requiredPrefix] ||
        ![NSFileManager.defaultManager fileExistsAtPath:standardized] ||
        ![NSFileManager.defaultManager
            fileExistsAtPath:[standardized stringByAppendingString:@".fuel"]]) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME loose_preload_failed image=%@ "
            "reason=artifact_missing", candidate);
      return NO;
    }
    NSLog(@"AIJIN_PLAYBOX_RUNTIME loose_preload image=%@", candidate);
    void *handle =
        AijinAdversarysOpenLoose(standardized.fileSystemRepresentation);
    if (handle == NULL) {
      const char *error = AijinAdversarysError();
      NSLog(@"AIJIN_PLAYBOX_RUNTIME loose_preload_failed image=%@ error=%s",
            candidate, error == NULL ? "unknown" : error);
      return NO;
    }
    [AijinLooseGuestImages addObject:[NSValue valueWithPointer:handle]];
  }
  NSLog(@"AIJIN_PLAYBOX_RUNTIME loose_preload_ready count=%lu",
        (unsigned long)AijinLooseGuestImages.count);
  return YES;
}

static void AijinSampleAdversarysThreads(void);
static void AijinStartDiagnosticFileBurst(NSString *reason);
static void AijinStartDiagnosticFocusedBurst(void);

static void AijinStartDiagnosticBurst(NSString *reason) {
  if (![NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-result-burst"] ||
      !__sync_bool_compare_and_swap(&AijinDiagnosticBurstStarted, 0, 1)) {
    return;
  }
  NSLog(@"AIJIN_DIAGNOSTIC_BURST start reason=%@", reason);
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    for (NSUInteger index = 0;
         index < 6000 &&
             AijinDiagnosticSampleCount < AijinDiagnosticSampleLimit;
         index += 1) {
      AijinSampleAdversarysThreads();
      usleep(500);
    }
    NSLog(@"AIJIN_DIAGNOSTIC_BURST end samples=%d",
          AijinDiagnosticSampleCount);
  });
}

static void AijinProbeLocalProxy(NSString *host, NSString *port) {
  NSString *hostCopy = [host copy];
  NSString *portCopy = [port copy];
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
    int descriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (descriptor < 0) {
      NSLog(@"AIJIN_NATIVE_YUNCENG probe_socket_failed errno=%d", errno);
      return;
    }
    int flags = fcntl(descriptor, F_GETFL, 0);
    if (flags >= 0) {
      fcntl(descriptor, F_SETFL, flags | O_NONBLOCK);
    }
    struct sockaddr_in address = {0};
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons((uint16_t)portCopy.intValue);
    int converted = inet_pton(AF_INET, hostCopy.UTF8String,
                              &address.sin_addr);
    int result = converted == 1
        ? connect(descriptor, (const struct sockaddr *)&address,
                  sizeof(address))
        : -1;
    int connectError = result == 0 ? 0 : errno;
    if (result != 0 && connectError == EINPROGRESS) {
      fd_set writeSet;
      FD_ZERO(&writeSet);
      FD_SET(descriptor, &writeSet);
      struct timeval timeout = {.tv_sec = 2, .tv_usec = 0};
      int selected = select(descriptor + 1, NULL, &writeSet, NULL, &timeout);
      if (selected > 0) {
        socklen_t errorLength = sizeof(connectError);
        getsockopt(descriptor, SOL_SOCKET, SO_ERROR, &connectError,
                   &errorLength);
      } else {
        connectError = selected == 0 ? ETIMEDOUT : errno;
      }
    }
    NSLog(@"AIJIN_NATIVE_YUNCENG probe target=%@:%@ errno=%d", hostCopy,
          portCopy, connectError);
    close(descriptor);
  });
}

typedef int (*AijinKiwiInitWithListenerFunction)(id, SEL, const char *, id);

static int AijinObservedConnect(int descriptor,
                                 const struct sockaddr *address,
                                 socklen_t addressLength) {
  static int (*systemConnect)(int, const struct sockaddr *, socklen_t);
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    systemConnect = dlsym(RTLD_NEXT, "connect");
  });
  int result = systemConnect == NULL
      ? -1
      : systemConnect(descriptor, address, addressLength);
  int savedError = result == 0 ? 0 : errno;
  if (address != NULL && address->sa_family == AF_INET &&
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-observe-connect"]) {
    const struct sockaddr_in *ipv4 = (const struct sockaddr_in *)address;
    char target[INET_ADDRSTRLEN] = {0};
    inet_ntop(AF_INET, &ipv4->sin_addr, target, sizeof(target));
    Dl_info callerInfo = {0};
    const void *caller = __builtin_return_address(0);
    dladdr(caller, &callerInfo);
    NSString *callerImage = callerInfo.dli_fname == NULL
        ? @"unknown"
        : [NSString stringWithUTF8String:callerInfo.dli_fname]
              .lastPathComponent;
    NSLog(@"AIJIN_CONNECT target=%s:%u result=%d errno=%d caller=%@ offset=%#lx",
          target, ntohs(ipv4->sin_port), result, savedError, callerImage,
          callerInfo.dli_fbase == NULL
              ? 0UL
              : (unsigned long)((uintptr_t)caller -
                                (uintptr_t)callerInfo.dli_fbase));
  }
  errno = savedError;
  return result;
}

static int AijinObservedKill(pid_t process, int signalNumber) {
  static int (*systemKill)(pid_t, int);
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    systemKill = dlsym(RTLD_NEXT, "kill");
  });
  void *frames[48] = {0};
  int count = backtrace(frames, (int)(sizeof(frames) / sizeof(frames[0])));
  dprintf(STDERR_FILENO,
          "AIJIN_DIAGNOSTIC_KILL pid=%d signal=%d frames=%d\n",
          process, signalNumber, count);
  backtrace_symbols_fd(frames, count, STDERR_FILENO);
  if (signalNumber == SIGKILL &&
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-ignore-runtime-sigkill"]) {
    dprintf(STDERR_FILENO, "AIJIN_DIAGNOSTIC_KILL ignored\n");
    return 0;
  }
  return systemKill == NULL ? -1 : systemKill(process, signalNumber);
}

#define AIJIN_DYLD_INTERPOSE(_replacement, _replacee)                       \
  __attribute__((used)) static struct {                                      \
    const void *replacement;                                                 \
    const void *replacee;                                                    \
  } _aijin_interpose_##_replacee __attribute__((section("__DATA,__interpose"))) = { \
      (const void *)(unsigned long)&_replacement,                            \
      (const void *)(unsigned long)&_replacee};

typedef void (*AijinDispatchOnceFunction)(void *);
typedef void (*AijinDispatchOnceFFunction)(dispatch_once_t *, void *,
                                            AijinDispatchOnceFunction);
typedef void *(*AijinDlsymFunction)(void *, const char *);
typedef void *(*AijinGuestCallbackBuilderFunction)(
    void *, uint32_t, void *, uintptr_t, uintptr_t);
static AijinDispatchOnceFFunction AijinSystemDispatchOnceF;
static AijinDlsymFunction AijinSystemDlsym;
static uintptr_t AijinLastGuestCallbackAddress;
static AijinDispatchOnceFunction AijinLastGuestCallbackTrampoline;

static AijinDispatchOnceFunction
AijinGuestCallbackTrampoline(uintptr_t guestAddress) {
  uintptr_t cachedAddress = __atomic_load_n(
      &AijinLastGuestCallbackAddress, __ATOMIC_ACQUIRE);
  if (cachedAddress == guestAddress) {
    return __atomic_load_n(
        &AijinLastGuestCallbackTrampoline, __ATOMIC_RELAXED);
  }
  if (AijinDiagnosticAdversarysBase == 0 || guestAddress == 0) {
    return NULL;
  }

  // adversarys keeps every loaded guest image in a sorted runtime vector.
  // Its stock symbol resolver uses these same fields before calling the
  // signed callback-thunk builder at +0x7dc8. Reuse that mechanism for guest
  // function pointers passed as arguments to native APIs.
  void *runtime = *(void **)(AijinDiagnosticAdversarysBase + 0x062DE770);
  if (runtime == NULL) {
    return NULL;
  }
  uintptr_t imageCursor = *(uintptr_t *)((uintptr_t)runtime + 0x80);
  uintptr_t imageEnd = *(uintptr_t *)((uintptr_t)runtime + 0x88);
  if (imageCursor == 0 || imageEnd < imageCursor ||
      imageEnd - imageCursor > 0x20000 ||
      ((imageEnd - imageCursor) % sizeof(uintptr_t)) != 0) {
    return NULL;
  }

  void *guestImage = NULL;
  uintptr_t matchedImageStart = 0;
  uintptr_t matchedImageLimit = 0;
  NSUInteger matchedImageIndex = NSNotFound;
  NSUInteger imageIndex = 0;
  for (; imageCursor < imageEnd; imageCursor += sizeof(uintptr_t)) {
    void *candidate = *(void **)imageCursor;
    if (candidate == NULL) {
      imageIndex += 1;
      continue;
    }
    uintptr_t imageStart = *(uintptr_t *)((uintptr_t)candidate + 0x30);
    uintptr_t imageLimit = *(uintptr_t *)((uintptr_t)candidate + 0x38);
    if (guestAddress >= imageStart && guestAddress < imageLimit) {
      guestImage = candidate;
      matchedImageStart = imageStart;
      matchedImageLimit = imageLimit;
      matchedImageIndex = imageIndex;
      break;
    }
    imageIndex += 1;
  }
  if (guestImage == NULL) {
    char buffer[256] = {0};
    int length = snprintf(
        buffer, sizeof(buffer),
        "AIJIN_DIAGNOSTIC_GUEST_CALLBACK_MISS guest=%#lx "
        "vector_start=%#lx vector_end=%#lx\n",
        (unsigned long)guestAddress,
        (unsigned long)*(uintptr_t *)((uintptr_t)runtime + 0x80),
        (unsigned long)*(uintptr_t *)((uintptr_t)runtime + 0x88));
    if (length > 0) {
      size_t writeLength = (size_t)MIN(length, (int)sizeof(buffer) - 1);
      write(STDERR_FILENO, buffer, writeLength);
      if (AijinDiagnosticSignalFile >= 0) {
        write(AijinDiagnosticSignalFile, buffer, writeLength);
        fsync(AijinDiagnosticSignalFile);
      }
    }
    return NULL;
  }

  char matchBuffer[320] = {0};
  int matchLength = snprintf(
      matchBuffer, sizeof(matchBuffer),
      "AIJIN_DIAGNOSTIC_GUEST_CALLBACK_MATCH guest=%#lx image=%p "
      "index=%lu start=%#lx end=%#lx offset=%#lx\n",
      (unsigned long)guestAddress, guestImage,
      (unsigned long)matchedImageIndex, (unsigned long)matchedImageStart,
      (unsigned long)matchedImageLimit,
      (unsigned long)(guestAddress - matchedImageStart));
  if (matchLength > 0) {
    size_t writeLength =
        (size_t)MIN(matchLength, (int)sizeof(matchBuffer) - 1);
    write(STDERR_FILENO, matchBuffer, writeLength);
    if (AijinDiagnosticSignalFile >= 0) {
      write(AijinDiagnosticSignalFile, matchBuffer, writeLength);
      fsync(AijinDiagnosticSignalFile);
    }
  }

  AijinGuestCallbackBuilderFunction builder =
      (AijinGuestCallbackBuilderFunction)(
          AijinDiagnosticAdversarysBase + 0x00007DC8);
  AijinDispatchOnceFunction trampoline =
      (AijinDispatchOnceFunction)builder(
          runtime, 6, guestImage, guestAddress, 0);
  if (trampoline != NULL) {
    __atomic_store_n(
        &AijinLastGuestCallbackTrampoline, trampoline, __ATOMIC_RELAXED);
    __atomic_store_n(
        &AijinLastGuestCallbackAddress, guestAddress, __ATOMIC_RELEASE);
    NSLog(@"AIJIN_GUEST_CALLBACK resolved guest=%#lx trampoline=%p image=%p",
          (unsigned long)guestAddress, trampoline, guestImage);
  }
  return trampoline;
}

// Upgrade raw guest function pointers to adversarys callback trampolines while
// forwarding ordinary native callbacks unchanged.  Rebinding adversarys'
// general dlsym import also intercepts unrelated Dart VM symbol discovery.
__attribute__((used, noinline)) static void
AijinDispatchOnceBoundary(dispatch_once_t *predicate, void *context,
                           dispatch_function_t function) {
  if (AijinSystemDispatchOnceF == NULL) {
    AijinSystemDispatchOnceF =
        (AijinDispatchOnceFFunction)dlsym(RTLD_NEXT, "dispatch_once_f");
  }
  AijinDispatchOnceFunction translated =
      AijinGuestCallbackTrampoline((uintptr_t)function);
  if (translated != NULL) {
    NSLog(@"AIJIN_GUEST_CALLBACK dispatch_once guest=%p trampoline=%p",
          function, translated);
  }
  if (AijinSystemDispatchOnceF != NULL) {
    AijinSystemDispatchOnceF(
        predicate, context,
        translated == NULL ? (AijinDispatchOnceFunction)function : translated);
  }
}

// dyld interposition covers both normal imports and the native function
// pointer adversarys caches internally.  The boundary itself only changes a
// callback that belongs to a loaded guest image.
__attribute__((used, noinline)) static void
AijinObservedDispatchOnceFImpl(dispatch_once_t *predicate, void *context,
                                AijinDispatchOnceFunction function,
                                uintptr_t guestState) {
  if (AijinDiagnosticDispatchOnceArmed) {
    uintptr_t guestPC = *(const uintptr_t *)(guestState + 0x140);
    const uintptr_t *guestRegisters =
        (const uintptr_t *)(guestState + 0x40);
    char buffer[1024] = {0};
    int length = snprintf(
        buffer, sizeof(buffer),
        "AIJIN_DIAGNOSTIC_DISPATCH_ONCE function=%#lx predicate=%#lx "
        "context=%#lx state=%#lx state_pc=%#lx x0=%#lx x1=%#lx x2=%#lx "
        "x8=%#lx x19=%#lx x20=%#lx x25=%#lx x27=%#lx x28=%#lx "
        "sp=%#lx\n",
        (unsigned long)function, (unsigned long)predicate,
        (unsigned long)context, (unsigned long)guestState,
        (unsigned long)guestPC, (unsigned long)guestRegisters[0],
        (unsigned long)guestRegisters[1], (unsigned long)guestRegisters[2],
        (unsigned long)guestRegisters[8], (unsigned long)guestRegisters[19],
        (unsigned long)guestRegisters[20], (unsigned long)guestRegisters[25],
        (unsigned long)guestRegisters[27], (unsigned long)guestRegisters[28],
        (unsigned long)guestRegisters[31]);
    if (length > 0) {
      size_t writeLength =
          (size_t)MIN(length, (int)sizeof(buffer) - 1);
      write(STDERR_FILENO, buffer, writeLength);
      if (AijinDiagnosticSignalFile >= 0) {
        write(AijinDiagnosticSignalFile, buffer, writeLength);
        fsync(AijinDiagnosticSignalFile);
      }
    }
  }
  if (AijinSystemDispatchOnceF != NULL) {
    AijinDispatchOnceFunction translated =
        AijinGuestCallbackTrampoline((uintptr_t)function);
    AijinSystemDispatchOnceF(
        predicate, context, translated == NULL ? function : translated);
  }
}

__attribute__((used, naked)) static void
AijinObservedDispatchOnceF(dispatch_once_t *predicate, void *context,
                            AijinDispatchOnceFunction function) {
  __asm__("mov x3, x14\n"
          "b _AijinObservedDispatchOnceFImpl\n");
}

// Keep non-target dlsym calls ABI-identical to adversarys' original path: the
// naked observer compares the exact 16 bytes of "dispatch_once_f\0" and tail
// branches to dyld for every other symbol without adding a C frame or changing
// LR, SP or the guest-state register in X14.
__attribute__((used, naked)) static void *
AijinObservedDlsym(void *handle, const char *symbol) {
  __asm__("cbz x1, 2f\n"
          "ldp x2, x3, [x1]\n"
          "movz x4, #0x6964\n"
          "movk x4, #0x7073, lsl #16\n"
          "movk x4, #0x7461, lsl #32\n"
          "movk x4, #0x6863, lsl #48\n"
          "cmp x2, x4\n"
          "b.ne 2f\n"
          "movz x5, #0x6f5f\n"
          "movk x5, #0x636e, lsl #16\n"
          "movk x5, #0x5f65, lsl #32\n"
          "movk x5, #0x0066, lsl #48\n"
          "cmp x3, x5\n"
          "b.ne 2f\n"
          "adrp x0, _AijinObservedDispatchOnceF@PAGE\n"
          "add x0, x0, _AijinObservedDispatchOnceF@PAGEOFF\n"
          "ret\n"
          "2:\n"
          "adrp x9, _AijinSystemDlsym@PAGE\n"
          "ldr x9, [x9, _AijinSystemDlsym@PAGEOFF]\n"
          "cbz x9, 3f\n"
          "br x9\n"
          "3:\n"
          "mov x0, #0\n"
          "ret\n");
}

AIJIN_DYLD_INTERPOSE(AijinObservedConnect, connect)
AIJIN_DYLD_INTERPOSE(AijinObservedKill, kill)

static void AijinRebindObservedSymbolsInImage(
    const struct mach_header *rawHeader, intptr_t slide) {
  if (rawHeader == NULL || rawHeader->magic != MH_MAGIC_64) {
    return;
  }
  const struct mach_header_64 *header =
      (const struct mach_header_64 *)rawHeader;
  Dl_info imageInfo = {0};
  dladdr(rawHeader, &imageInfo);
  BOOL isAdversarys =
      imageInfo.dli_fname != NULL &&
      strstr(imageInfo.dli_fname, "/adversarys.framework/adversarys") != NULL;
  BOOL bridgeGuestDlsym =
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-bridge-guest-callbacks"];
  BOOL bridgeDispatchOnceImport =
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-bridge-dispatch-once-import"];
  BOOL observeConnect =
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-observe-connect"];
  const struct symtab_command *symbolTableCommand = NULL;
  const struct dysymtab_command *dynamicSymbolTableCommand = NULL;
  const struct segment_command_64 *linkeditSegment = NULL;
  uintptr_t commandCursor = (uintptr_t)header + sizeof(*header);
  for (uint32_t index = 0; index < header->ncmds; index += 1) {
    const struct load_command *command =
        (const struct load_command *)commandCursor;
    if (command->cmd == LC_SYMTAB) {
      symbolTableCommand = (const struct symtab_command *)command;
    } else if (command->cmd == LC_DYSYMTAB) {
      dynamicSymbolTableCommand =
          (const struct dysymtab_command *)command;
    } else if (command->cmd == LC_SEGMENT_64) {
      const struct segment_command_64 *segment =
          (const struct segment_command_64 *)command;
      if (strcmp(segment->segname, SEG_LINKEDIT) == 0) {
        linkeditSegment = segment;
      }
    }
    commandCursor += command->cmdsize;
  }
  if (symbolTableCommand == NULL || dynamicSymbolTableCommand == NULL ||
      linkeditSegment == NULL) {
    return;
  }

  uintptr_t linkeditBase = (uintptr_t)slide + linkeditSegment->vmaddr -
      linkeditSegment->fileoff;
  const struct nlist_64 *symbols = (const struct nlist_64 *)(
      linkeditBase + symbolTableCommand->symoff);
  const char *strings = (const char *)(linkeditBase +
                                      symbolTableCommand->stroff);
  const uint32_t *indirectSymbols = (const uint32_t *)(
      linkeditBase + dynamicSymbolTableCommand->indirectsymoff);

  commandCursor = (uintptr_t)header + sizeof(*header);
  for (uint32_t commandIndex = 0; commandIndex < header->ncmds;
       commandIndex += 1) {
    const struct load_command *command =
        (const struct load_command *)commandCursor;
    if (command->cmd == LC_SEGMENT_64) {
      const struct segment_command_64 *segment =
          (const struct segment_command_64 *)command;
      const struct section_64 *sections =
          (const struct section_64 *)(segment + 1);
      for (uint32_t sectionIndex = 0; sectionIndex < segment->nsects;
           sectionIndex += 1) {
        const struct section_64 *section = &sections[sectionIndex];
        uint32_t sectionType = section->flags & SECTION_TYPE;
        if (sectionType != S_LAZY_SYMBOL_POINTERS &&
            sectionType != S_NON_LAZY_SYMBOL_POINTERS) {
          continue;
        }
        uintptr_t *bindings = (uintptr_t *)(slide + section->addr);
        uint32_t bindingCount = (uint32_t)(section->size / sizeof(uintptr_t));
        for (uint32_t bindingIndex = 0; bindingIndex < bindingCount;
             bindingIndex += 1) {
          uint32_t symbolIndex =
              indirectSymbols[section->reserved1 + bindingIndex];
          if (symbolIndex == INDIRECT_SYMBOL_ABS ||
              symbolIndex == INDIRECT_SYMBOL_LOCAL ||
              symbolIndex == (INDIRECT_SYMBOL_LOCAL | INDIRECT_SYMBOL_ABS)) {
            continue;
          }
          const char *name = strings + symbols[symbolIndex].n_un.n_strx;
          BOOL rebindConnect =
              observeConnect && name != NULL && strcmp(name, "_connect") == 0;
          BOOL rebindDlsym =
              isAdversarys && bridgeGuestDlsym && name != NULL &&
              strcmp(name, "_dlsym") == 0;
          BOOL rebindDispatchOnce =
              isAdversarys && bridgeDispatchOnceImport && name != NULL &&
              strcmp(name, "_dispatch_once_f") == 0;
          if (!rebindConnect && !rebindDlsym && !rebindDispatchOnce) {
            continue;
          }
          vm_address_t page = (vm_address_t)&bindings[bindingIndex] &
              ~((vm_address_t)vm_page_size - 1);
          kern_return_t protection = vm_protect(
              mach_task_self(), page, vm_page_size, false,
              VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
          if (protection != KERN_SUCCESS) {
            NSLog(@"AIJIN_CONNECT rebind_protect_failed code=%d", protection);
            continue;
          }
          if (rebindDlsym) {
            if (AijinSystemDlsym == NULL) {
              AijinSystemDlsym =
                  (AijinDlsymFunction)bindings[bindingIndex];
            }
            bindings[bindingIndex] = (uintptr_t)&AijinObservedDlsym;
            NSLog(@"AIJIN_DIAGNOSTIC_DISPATCH_ONCE dlsym_rebound "
                  "image=%s section=%s",
                  imageInfo.dli_fname ?: "unknown", section->sectname);
          } else if (rebindDispatchOnce) {
            if (AijinSystemDispatchOnceF == NULL) {
              AijinSystemDispatchOnceF =
                  (AijinDispatchOnceFFunction)bindings[bindingIndex];
            }
            bindings[bindingIndex] =
                (uintptr_t)&AijinDispatchOnceBoundary;
            NSLog(@"AIJIN_GUEST_CALLBACK dispatch_once_import_rebound "
                  "image=%s section=%s original=%p",
                  imageInfo.dli_fname ?: "unknown", section->sectname,
                  AijinSystemDispatchOnceF);
          } else {
            bindings[bindingIndex] = (uintptr_t)&AijinObservedConnect;
            NSLog(@"AIJIN_CONNECT rebound image=%s section=%s",
                  imageInfo.dli_fname ?: "unknown", section->sectname);
          }
        }
      }
    }
    commandCursor += command->cmdsize;
  }
}

static void AijinInstallConnectObservation(void) {
  uint32_t count = _dyld_image_count();
  for (uint32_t index = 0; index < count; index += 1) {
    AijinRebindObservedSymbolsInImage(
        _dyld_get_image_header(index),
        _dyld_get_image_vmaddr_slide(index));
  }
  _dyld_register_func_for_add_image(AijinRebindObservedSymbolsInImage);
  NSLog(@"AIJIN_CONNECT observation_installed images=%u", count);
}

static void AijinInstallGuestCallbackBridges(void) {
  uint32_t count = _dyld_image_count();
  for (uint32_t index = 0; index < count; index += 1) {
    AijinRebindObservedSymbolsInImage(
        _dyld_get_image_header(index),
        _dyld_get_image_vmaddr_slide(index));
  }
  if (AijinSystemDispatchOnceF == NULL && AijinSystemDlsym != NULL) {
    AijinSystemDispatchOnceF = (AijinDispatchOnceFFunction)
        AijinSystemDlsym(RTLD_DEFAULT, "dispatch_once_f");
  }
  NSLog(@"AIJIN_GUEST_CALLBACK bridges_installed images=%u "
        "dlsym=%p dispatch_once_f=%p",
        count, AijinSystemDlsym, AijinSystemDispatchOnceF);
}

static int AijinDyzbGuestKiwiInitBridge(id receiver, SEL selector,
                                         const char *configuration) {
  (void)receiver;
  NSLog(@"AIJIN_KIWI_CLASS init_start main=%d", NSThread.isMainThread);
  int result = ((int (*)(id, SEL, const char *))AijinNativeKiwiInit)(
      AijinNativeKiwiClass, selector, configuration);
  NSLog(@"AIJIN_KIWI_CLASS init_return result=%d", result);
  return result;
}

static NSString *AijinImageForAddress(const void *address) {
  Dl_info imageInfo = {0};
  if (address == NULL || dladdr(address, &imageInfo) == 0 ||
      imageInfo.dli_fname == NULL) {
    return @"unknown";
  }
  return [NSString stringWithUTF8String:imageInfo.dli_fname].lastPathComponent;
}

// Kiwi's stock implementation runs the supplied completion block on an
// NSOperationQueue.  A translated guest block may only be safely entered from
// the main thread, so keep the real network initialization and bridge just its
// completion back to the main queue.
static int AijinKiwiInitWithListenerBridge(id receiver, SEL selector,
                                             const char *configuration,
                                             id listener) {
  const void *guestInvoke = NULL;
  if (listener != nil) {
    guestInvoke = ((const void *const *)(__bridge const void *)listener)[2];
  }
  NSLog(@"AIJIN_KIWI_BRIDGE start listener=%p invoke=%p image=%@ main=%d",
        (__bridge void *)listener, guestInvoke,
        AijinImageForAddress(guestInvoke), NSThread.isMainThread);

  id guestListener = [listener copy];
  void (^hostListener)(int) = ^(int result) {
    NSLog(@"AIJIN_KIWI_BRIDGE native_complete result=%d main=%d", result,
          NSThread.isMainThread);
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"AIJIN_KIWI_BRIDGE guest_callback result=%d invoke=%p image=%@",
            result, guestInvoke, AijinImageForAddress(guestInvoke));
      if (guestListener != nil) {
        ((void (^)(int))guestListener)(result);
      }
      NSLog(@"AIJIN_KIWI_BRIDGE guest_callback_returned result=%d", result);
    });
  };
  return ((AijinKiwiInitWithListenerFunction)
      AijinOriginalKiwiInitWithListener)(receiver, selector, configuration,
                                          hostListener);
}

static BOOL AijinInstallKiwiListenerBridge(void) {
  Class kiwiClass = NSClassFromString(@"Kiwi");
  SEL selector = NSSelectorFromString(@"InitWithListener::");
  Method method = kiwiClass == Nil
      ? NULL
      : class_getClassMethod(kiwiClass, selector);
  if (method == NULL) {
    NSLog(@"AIJIN_KIWI_BRIDGE install_failed class=%@",
          NSStringFromClass(kiwiClass));
    return NO;
  }
  AijinNativeKiwiClass = kiwiClass;
  IMP current = method_getImplementation(method);
  if (current != (IMP)AijinKiwiInitWithListenerBridge) {
    AijinOriginalKiwiInitWithListener = current;
    method_setImplementation(method, (IMP)AijinKiwiInitWithListenerBridge);
  }
  NSLog(@"AIJIN_KIWI_BRIDGE installed original=%p image=%@", current,
        AijinImageForAddress((const void *)current));
  return YES;
}

static id AijinFlutterCallArguments(id call) {
  SEL selector = NSSelectorFromString(@"arguments");
  if (call == nil || ![call respondsToSelector:selector]) {
    return nil;
  }
  return ((id (*)(id, SEL))objc_msgSend)(call, selector);
}

static void AijinNativeYunCengHandleMethodCall(id plugin, SEL selector,
                                                id call, id resultCallback) {
  (void)selector;
  SEL methodSelector = NSSelectorFromString(@"method");
  NSString *method = [call respondsToSelector:methodSelector]
      ? ((id (*)(id, SEL))objc_msgSend)(call, methodSelector)
      : nil;
  NSDictionary *arguments = AijinFlutterCallArguments(call);
  const uintptr_t *resultWords = resultCallback == nil
      ? NULL
      : (const uintptr_t *)(__bridge const void *)resultCallback;
  id resultCodec = resultWords == NULL
      ? nil
      : (__bridge id)(void *)resultWords[4];
  id binaryReply = resultWords == NULL
      ? nil
      : (__bridge id)(void *)resultWords[5];
  const void *binaryReplyInvoke = binaryReply == nil
      ? NULL
      : ((const void *const *)(__bridge const void *)binaryReply)[2];
  NSLog(@"AIJIN_NATIVE_YUNCENG call method=%@ result_image=%@ "
         "codec=%@/%s binary_reply_image=%@",
        method,
        resultCallback == nil
            ? @"none"
            : AijinImageForAddress(
                  ((const void *const *)(__bridge const void *)
                      resultCallback)[2]),
        NSStringFromClass([resultCodec class]),
        resultCodec == nil
            ? "none"
            : (class_getImageName([resultCodec class]) ?: "unknown"),
        AijinImageForAddress(binaryReplyInvoke));

  int code = -1;
  BOOL focusInstallResult = NO;
  id resultValue = nil;
  if ([method isEqualToString:@"initEx"]) {
    NSString *token = [arguments isKindOfClass:NSDictionary.class]
        ? arguments[@"token"]
        : nil;
    NSString *appKey = [arguments isKindOfClass:NSDictionary.class]
        ? arguments[@"appKey"]
        : nil;
    if ([token isKindOfClass:NSString.class]) {
      objc_setAssociatedObject(plugin,
                               &AijinNativeYunCengTokenAssociationKey,
                               token, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    Class kiwiClass = AijinNativeKiwiClass ?: NSClassFromString(@"Kiwi");
    SEL initSelector = NSSelectorFromString(@"Init:");
    Method initMethod = kiwiClass == Nil
        ? NULL
        : class_getClassMethod(kiwiClass, initSelector);
    if (initMethod != NULL && [appKey isKindOfClass:NSString.class]) {
      int (*initFunction)(id, SEL, const char *) =
          (int (*)(id, SEL, const char *))method_getImplementation(initMethod);
      code = initFunction(kiwiClass, initSelector, appKey.UTF8String);
    }
    resultValue = @(code);
  } else if ([method isEqualToString:@"restartAllServer"]) {
    Class kiwiClass = AijinNativeKiwiClass ?: NSClassFromString(@"Kiwi");
    SEL restartSelector = NSSelectorFromString(@"RestartAllServer");
    Method restartMethod = kiwiClass == Nil
        ? NULL
        : class_getClassMethod(kiwiClass, restartSelector);
    if (restartMethod != NULL) {
      code = ((int (*)(id, SEL))method_getImplementation(restartMethod))(
          kiwiClass, restartSelector);
    }
    resultValue = @(code);
  } else if ([method isEqualToString:@"getProxyTcpByDomain"]) {
    NSString *groupName = [arguments isKindOfClass:NSDictionary.class]
        ? arguments[@"group_name"]
        : nil;
    NSString *directDomain = [arguments isKindOfClass:NSDictionary.class]
        ? arguments[@"ddomain"]
        : nil;
    id directPort = [arguments isKindOfClass:NSDictionary.class]
        ? arguments[@"dport"]
        : nil;
    focusInstallResult = [groupName isEqualToString:@"kiwi_install"];
    char targetIP[128] = {0};
    char targetPort[40] = {0};
    Class kiwiClass = AijinNativeKiwiClass ?: NSClassFromString(@"Kiwi");
    SEL proxySelector = NSSelectorFromString(@"ServerToLocal:::::");
    Method proxyMethod = kiwiClass == Nil
        ? NULL
        : class_getClassMethod(kiwiClass, proxySelector);
    if (proxyMethod != NULL && [groupName isKindOfClass:NSString.class]) {
      int (*proxyFunction)(id, SEL, const char *, char *, int, char *, int) =
          (int (*)(id, SEL, const char *, char *, int, char *, int))
              method_getImplementation(proxyMethod);
      code = proxyFunction(kiwiClass, proxySelector, groupName.UTF8String,
                           targetIP, (int)sizeof(targetIP), targetPort,
                           (int)sizeof(targetPort));
    }
    NSString *targetIPString = [NSString stringWithUTF8String:targetIP] ?: @"";
    NSString *targetPortString =
        [NSString stringWithUTF8String:targetPort] ?: @"";
    NSMutableDictionary *proxyResult = [NSMutableDictionary dictionary];
    [proxyResult setObject:[NSString stringWithFormat:@"%i", code]
                    forKey:@"code"];
    [proxyResult setObject:targetIPString forKey:@"target_ip"];
    [proxyResult setObject:targetPortString forKey:@"target_port"];
    resultValue = proxyResult;
    NSLog(@"AIJIN_NATIVE_YUNCENG proxy group=%@ direct=%@:%@ code=%d "
           "target=%@:%@ main=%d",
          groupName, directDomain, directPort, code, targetIPString,
          targetPortString, NSThread.isMainThread);
    if (code == 0 && targetIPString.length > 0 &&
        targetPortString.integerValue > 0 &&
        [NSProcessInfo.processInfo.arguments
            containsObject:@"--aijin-probe-local-proxy"]) {
      AijinProbeLocalProxy(targetIPString, targetPortString);
    }
  }
  NSLog(@"AIJIN_NATIVE_YUNCENG result method=%@ code=%d", method, code);
  if (resultCallback != nil) {
    if ([method isEqualToString:@"initEx"] &&
        [NSProcessInfo.processInfo.arguments
            containsObject:@"--aijin-debug-delay-kiwi-result"]) {
      id delayedCallback = [resultCallback copy];
      id delayedValue = resultValue ?: @(code);
      NSLog(@"AIJIN_NATIVE_YUNCENG delaying_init_result seconds=15");
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC),
                     dispatch_get_main_queue(), ^{
        NSLog(@"AIJIN_NATIVE_YUNCENG delivering_delayed_init_result");
        ((void (^)(id))delayedCallback)(delayedValue);
      });
      return;
    }
    if ([method isEqualToString:@"getProxyTcpByDomain"]) {
      AijinStartDiagnosticBurst(method);
      AijinStartDiagnosticFileBurst(method);
    }
    if (focusInstallResult &&
        [NSProcessInfo.processInfo.arguments
            containsObject:@"--aijin-diagnostic-focused-result"]) {
      AijinStartDiagnosticFocusedBurst();
    }
    if (focusInstallResult &&
        [NSProcessInfo.processInfo.arguments
            containsObject:@"--aijin-async-kiwi-install-result"]) {
      id delayedCallback = [resultCallback copy];
      id delayedValue = resultValue ?: @(code);
      NSLog(@"AIJIN_NATIVE_YUNCENG scheduling_async_install_result");
      dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"AIJIN_NATIVE_YUNCENG delivering_async_install_result");
        ((void (^)(id))delayedCallback)(delayedValue);
        NSLog(@"AIJIN_NATIVE_YUNCENG async_install_result_returned");
      });
      return;
    }
    ((void (^)(id))resultCallback)(resultValue ?: @(code));
    NSLog(@"AIJIN_NATIVE_YUNCENG result_returned method=%@ code=%d", method,
          code);
  }
}

static void AijinNativeYunCengRegister(id pluginClass, SEL selector,
                                        id registrar) {
  (void)selector;
  id existingPlugin = objc_getAssociatedObject(
      registrar, &AijinNativeYunCengPluginAssociationKey);
  if (existingPlugin != nil) {
    NSLog(@"AIJIN_NATIVE_YUNCENG register_skipped reason=already_registered");
    return;
  }
  SEL messengerSelector = NSSelectorFromString(@"messenger");
  id messenger = ((id (*)(id, SEL))objc_msgSend)(registrar,
                                                  messengerSelector);
  Class channelClass = AijinNativeFlutterMethodChannelClass ?:
      NSClassFromString(@"FlutterMethodChannel");
  SEL channelSelector =
      NSSelectorFromString(@"methodChannelWithName:binaryMessenger:");
  Method channelFactory = channelClass == Nil
      ? NULL
      : class_getClassMethod(channelClass, channelSelector);
  id channel = ((id (*)(id, SEL, id, id))objc_msgSend)(
      channelClass, channelSelector, @"flutter_yun_ceng_kiwi", messenger);
  id plugin = ((id (*)(id, SEL))objc_msgSend)(pluginClass,
                                               NSSelectorFromString(@"new"));
  // Calling FlutterPluginRegistrar's addMethodCallDelegate here re-enters the
  // translated guest registrar.  Its wrapper manufactures a result block in
  // adversarys, so the native result dictionary has to cross back through the
  // VM before Flutter's codec can send it to Dart.  Register directly on the
  // process-wide native FlutterMethodChannel instead.  That keeps decoding,
  // the result callback, envelope encoding, and binary reply in Flutter.framework.
  id handler = [^(id call, id resultCallback) {
    AijinNativeYunCengHandleMethodCall(
        plugin, NSSelectorFromString(@"handleMethodCall:result:"), call,
        resultCallback);
  } copy];
  SEL handlerSelector = NSSelectorFromString(@"setMethodCallHandler:");
  ((void (*)(id, SEL, id))objc_msgSend)(channel, handlerSelector, handler);
  objc_setAssociatedObject(registrar,
                           &AijinNativeYunCengPluginAssociationKey,
                           plugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(plugin,
                           &AijinNativeYunCengChannelAssociationKey,
                           channel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(plugin,
                           &AijinNativeYunCengHandlerAssociationKey,
                           handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  Method handlerMethod = channelClass == Nil
      ? NULL
      : class_getInstanceMethod(channelClass, handlerSelector);
  NSLog(@"AIJIN_NATIVE_YUNCENG registered class=%@ registrar=%@/%s "
         "messenger=%@/%s channel=%@/%s factory_image=%@ handler_image=%@",
        NSStringFromClass(pluginClass), NSStringFromClass([registrar class]),
        class_getImageName([registrar class]) ?: "unknown",
        NSStringFromClass([messenger class]),
        class_getImageName([messenger class]) ?: "unknown", channel,
        class_getImageName([channel class]) ?: "unknown",
        AijinImageForAddress(channelFactory == NULL
                                  ? NULL
                                  : (const void *)method_getImplementation(
                                        channelFactory)),
        AijinImageForAddress(handlerMethod == NULL
                                  ? NULL
                                  : (const void *)method_getImplementation(
                                        handlerMethod)));
}

static BOOL AijinInstallNativeYunCengPluginClass(void) {
  // Capture this before adversarys opens the guest Flutter.framework.  After
  // that point NSClassFromString resolves the translated duplicate instead of
  // the already-loaded native Flutter.framework class.
  AijinNativeFlutterMethodChannelClass =
      NSClassFromString(@"FlutterMethodChannel");
  NSLog(@"AIJIN_NATIVE_YUNCENG native_channel_class=%p image=%s",
        AijinNativeFlutterMethodChannelClass,
        AijinNativeFlutterMethodChannelClass == Nil
            ? "missing"
            : (class_getImageName(AijinNativeFlutterMethodChannelClass) ?:
               "unknown"));
  Class existing = NSClassFromString(@"FlutterYunCengKiwiPlugin");
  if (existing != Nil) {
    AijinNativeYunCengPluginClass = existing;
    return YES;
  }
  Class pluginClass = objc_allocateClassPair(
      NSObject.class, "FlutterYunCengKiwiPlugin", 0);
  if (pluginClass == Nil) {
    NSLog(@"AIJIN_NATIVE_YUNCENG class_allocate_failed");
    return NO;
  }
  class_addMethod(pluginClass,
                  NSSelectorFromString(@"handleMethodCall:result:"),
                  (IMP)AijinNativeYunCengHandleMethodCall,
                  "v32@0:8@16@?24");
  class_addMethod(object_getClass(pluginClass),
                  NSSelectorFromString(@"registerWithRegistrar:"),
                  (IMP)AijinNativeYunCengRegister,
                  "v24@0:8@16");
  objc_registerClassPair(pluginClass);
  AijinNativeYunCengPluginClass = pluginClass;
  NSLog(@"AIJIN_NATIVE_YUNCENG class_ready class=%p", pluginClass);
  return YES;
}

static void AijinDyzbKiwiInitExBridge(id plugin, SEL selector, id call,
                                        id resultCallback) {
  (void)selector;
  NSDictionary *arguments = AijinFlutterCallArguments(call);
  NSString *token = [arguments isKindOfClass:NSDictionary.class]
      ? arguments[@"token"]
      : nil;
  NSString *appKey = [arguments isKindOfClass:NSDictionary.class]
      ? arguments[@"appKey"]
      : nil;
  Ivar tokenIvar = class_getInstanceVariable([plugin class], "_token");
  if (tokenIvar != NULL && [token isKindOfClass:NSString.class]) {
    object_setIvar(plugin, tokenIvar, token);
  }

  Class kiwiClass = AijinNativeKiwiClass ?: NSClassFromString(@"Kiwi");
  SEL initSelector = NSSelectorFromString(@"Init:");
  Method initMethod = kiwiClass == Nil
      ? NULL
      : class_getClassMethod(kiwiClass, initSelector);
  NSLog(@"AIJIN_KIWI_PLUGIN init_start class=%@ app_key_length=%lu main=%d",
        NSStringFromClass(kiwiClass), (unsigned long)appKey.length,
        NSThread.isMainThread);
  int code = -1;
  if (initMethod != NULL && [appKey isKindOfClass:NSString.class]) {
    int (*initFunction)(id, SEL, const char *) =
        (int (*)(id, SEL, const char *))method_getImplementation(initMethod);
    code = initFunction(kiwiClass, initSelector, appKey.UTF8String);
  }
  NSLog(@"AIJIN_KIWI_PLUGIN init_return code=%d", code);
  if (resultCallback != nil) {
    id copiedResultCallback = [resultCallback copy];
    const void *resultInvoke =
        ((const void *const *)(__bridge const void *)copiedResultCallback)[2];
    NSLog(@"AIJIN_KIWI_PLUGIN result_scheduled block=%p invoke=%p image=%@",
          (__bridge void *)resultCallback, resultInvoke,
          AijinImageForAddress(resultInvoke));
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"AIJIN_KIWI_PLUGIN result_start code=%d", code);
      ((void (^)(id))copiedResultCallback)(@(code));
      NSLog(@"AIJIN_KIWI_PLUGIN result_returned code=%d", code);
    });
  }
}

static BOOL AijinInstallDyzbKiwiPluginBridge(void) {
  Class pluginClass = NSClassFromString(@"FlutterYunCengKiwiPlugin");
  SEL selector = NSSelectorFromString(@"initEx:result:");
  Method method = pluginClass == Nil
      ? NULL
      : class_getInstanceMethod(pluginClass, selector);
  if (method == NULL) {
    NSLog(@"AIJIN_KIWI_PLUGIN install_failed class=%@",
          NSStringFromClass(pluginClass));
    return NO;
  }
  IMP original = method_getImplementation(method);
  method_setImplementation(method, (IMP)AijinDyzbKiwiInitExBridge);
  NSLog(@"AIJIN_KIWI_PLUGIN installed original=%p image=%@", original,
        AijinImageForAddress((const void *)original));
  return YES;
}

static void AijinPrepareDyzbKiwiThenRunGuest(id plugin, SEL selector, id call,
                                               id resultCallback) {
  NSDictionary *arguments = AijinFlutterCallArguments(call);
  NSString *appKey = [arguments isKindOfClass:NSDictionary.class]
      ? arguments[@"appKey"]
      : nil;
  Class kiwiClass = AijinNativeKiwiClass ?: NSClassFromString(@"Kiwi");
  SEL initSelector = NSSelectorFromString(@"Init:");
  Method initMethod = kiwiClass == Nil
      ? NULL
      : class_getClassMethod(kiwiClass, initSelector);
  int code = -1;
  if (initMethod != NULL && [appKey isKindOfClass:NSString.class]) {
    int (*initFunction)(id, SEL, const char *) =
        (int (*)(id, SEL, const char *))method_getImplementation(initMethod);
    NSLog(@"AIJIN_KIWI_PREPARE native_start app_key_length=%lu",
          (unsigned long)appKey.length);
    code = initFunction(kiwiClass, initSelector, appKey.UTF8String);
    NSLog(@"AIJIN_KIWI_PREPARE native_return code=%d", code);
  }
  NSLog(@"AIJIN_KIWI_PREPARE guest_enter imp=%p image=%@",
        AijinOriginalDyzbKiwiInitEx,
        AijinImageForAddress((const void *)AijinOriginalDyzbKiwiInitEx));
  Method method = class_getInstanceMethod([plugin class], selector);
  if (method != NULL) {
    method_setImplementation(method, AijinOriginalDyzbKiwiInitEx);
  }
  ((void (*)(id, SEL, id, id))objc_msgSend)(plugin, selector, call,
                                            resultCallback);
  NSLog(@"AIJIN_KIWI_PREPARE guest_returned");
}

static BOOL AijinInstallDyzbKiwiPrepareBridge(void) {
  Class pluginClass = NSClassFromString(@"FlutterYunCengKiwiPlugin");
  SEL selector = NSSelectorFromString(@"initEx:result:");
  Method method = pluginClass == Nil
      ? NULL
      : class_getInstanceMethod(pluginClass, selector);
  if (method == NULL) {
    NSLog(@"AIJIN_KIWI_PREPARE install_failed class=%@",
          NSStringFromClass(pluginClass));
    return NO;
  }
  AijinOriginalDyzbKiwiInitEx = method_getImplementation(method);
  method_setImplementation(method, (IMP)AijinPrepareDyzbKiwiThenRunGuest);
  NSLog(@"AIJIN_KIWI_PREPARE installed original=%p image=%@",
        AijinOriginalDyzbKiwiInitEx,
        AijinImageForAddress((const void *)AijinOriginalDyzbKiwiInitEx));
  return YES;
}

static BOOL AijinInstallDyzbKiwiClassBridge(void) {
  if (AijinNativeKiwiClass == Nil) {
    NSLog(@"AIJIN_KIWI_CLASS install_failed reason=native_class_missing");
    return NO;
  }
  int classCount = objc_getClassList(NULL, 0);
  if (classCount <= 0) {
    NSLog(@"AIJIN_KIWI_CLASS install_failed reason=empty_class_list");
    return NO;
  }
  __unsafe_unretained Class *classes =
      (__unsafe_unretained Class *)calloc((size_t)classCount, sizeof(Class));
  classCount = objc_getClassList(classes, classCount);
  Class guestKiwiClass = Nil;
  for (int index = 0; index < classCount; index += 1) {
    Class candidate = classes[index];
    if (candidate == AijinNativeKiwiClass ||
        strcmp(class_getName(candidate), "Kiwi") != 0) {
      continue;
    }
    guestKiwiClass = candidate;
    break;
  }
  free(classes);
  if (guestKiwiClass == Nil) {
    NSLog(@"AIJIN_KIWI_CLASS install_failed reason=guest_class_missing ");
    return NO;
  }

  unsigned int methodCount = 0;
  Method *guestMethods = class_copyMethodList(
      object_getClass(guestKiwiClass), &methodCount);
  unsigned int replaced = 0;
  for (unsigned int index = 0; index < methodCount; index += 1) {
    Method guestMethod = guestMethods[index];
    SEL selector = method_getName(guestMethod);
    Method nativeMethod = class_getClassMethod(AijinNativeKiwiClass, selector);
    if (nativeMethod == NULL ||
        strcmp(method_getTypeEncoding(guestMethod),
               method_getTypeEncoding(nativeMethod)) != 0) {
      continue;
    }
    IMP guestIMP = method_getImplementation(guestMethod);
    IMP nativeIMP = method_getImplementation(nativeMethod);
    IMP replacement = nativeIMP;
    if (strcmp(sel_getName(selector), "Init:") == 0) {
      AijinNativeKiwiInit = nativeIMP;
      replacement = (IMP)AijinDyzbGuestKiwiInitBridge;
    }
    method_setImplementation(guestMethod, replacement);
    replaced += 1;
    NSLog(@"AIJIN_KIWI_CLASS replaced selector=%@ guest_imp=%p guest_image=%@ "
          "native_imp=%p native_image=%@",
          NSStringFromSelector(selector), guestIMP,
          AijinImageForAddress((const void *)guestIMP), nativeIMP,
          AijinImageForAddress((const void *)nativeIMP));
  }
  free(guestMethods);
  NSLog(@"AIJIN_KIWI_CLASS installed guest=%p native=%p methods=%u",
        guestKiwiClass, AijinNativeKiwiClass, replaced);
  return replaced > 0;
}

static char *AijinAppendSignalText(char *cursor, const char *text) {
  while (*text != '\0') {
    *cursor++ = *text++;
  }
  return cursor;
}

static char *AijinAppendSignalHex(char *cursor, uintptr_t value) {
  static const char digits[] = "0123456789abcdef";
  *cursor++ = '0';
  *cursor++ = 'x';
  BOOL emitted = NO;
  for (int shift = (int)(sizeof(value) * 8) - 4; shift >= 0; shift -= 4) {
    unsigned digit = (unsigned)((value >> shift) & 0xF);
    if (digit != 0 || emitted || shift == 0) {
      *cursor++ = digits[digit];
      emitted = YES;
    }
  }
  return cursor;
}

static void AijinDiagnosticSignalHandler(int signalNumber,
                                          siginfo_t *signalInfo,
                                          void *rawContext) {
  ucontext_t *context = (ucontext_t *)rawContext;
  uintptr_t pc = context->uc_mcontext->__ss.__pc;
  uintptr_t lr = context->uc_mcontext->__ss.__lr;
  uintptr_t adversarysOffset = pc - AijinDiagnosticAdversarysBase;
  if (adversarysOffset == 0x0088BC30 && !AijinDiagnosticWatchArmed) {
    uintptr_t guestState = context->uc_mcontext->__ss.__x[14];
    AijinDiagnosticWatchGuestState = guestState;
    const uintptr_t *guestRegisters =
        (const uintptr_t *)(guestState + 0x40);
    AijinDiagnosticWatchAddress = guestRegisters[31] + 0x10;
    arm_debug_state64_t debugState = {0};
    mach_msg_type_number_t debugStateCount = ARM_DEBUG_STATE64_COUNT;
    thread_t currentThread = mach_thread_self();
    kern_return_t getResult = thread_get_state(
        currentThread, ARM_DEBUG_STATE64, (thread_state_t)&debugState,
        &debugStateCount);
    kern_return_t setResult = KERN_FAILURE;
    if (getResult == KERN_SUCCESS) {
      debugState.__wvr[0] = AijinDiagnosticWatchAddress;
      debugState.__wcr[0] = 0x1FF5;
      setResult = thread_set_state(
          currentThread, ARM_DEBUG_STATE64, (thread_state_t)&debugState,
          ARM_DEBUG_STATE64_COUNT);
    }
    mach_port_deallocate(mach_task_self(), currentThread);
    char setupBuffer[256];
    char *setupCursor = AijinAppendSignalText(
        setupBuffer, "AIJIN_DIAGNOSTIC_WATCH_SETUP address=");
    setupCursor = AijinAppendSignalHex(
        setupCursor, AijinDiagnosticWatchAddress);
    setupCursor = AijinAppendSignalText(setupCursor, " get=");
    setupCursor = AijinAppendSignalHex(setupCursor, (uintptr_t)getResult);
    setupCursor = AijinAppendSignalText(setupCursor, " set=");
    setupCursor = AijinAppendSignalHex(setupCursor, (uintptr_t)setResult);
    *setupCursor++ = '\n';
    write(STDERR_FILENO, setupBuffer, (size_t)(setupCursor - setupBuffer));
    if (setResult == KERN_SUCCESS) {
      AijinDiagnosticWatchArmed = 1;
      context->uc_mcontext->__ss.__pc += 4;
      return;
    }
  }
  char buffer[2048];
  char *cursor = AijinAppendSignalText(buffer, "AIJIN_DIAGNOSTIC_SIGNAL signal=");
  *cursor++ = (char)('0' + signalNumber / 10);
  *cursor++ = (char)('0' + signalNumber % 10);
  cursor = AijinAppendSignalText(cursor, " fault=");
  cursor = AijinAppendSignalHex(
      cursor, (uintptr_t)(signalInfo == NULL ? NULL : signalInfo->si_addr));
  cursor = AijinAppendSignalText(cursor, " pc=");
  cursor = AijinAppendSignalHex(cursor, pc);
  cursor = AijinAppendSignalText(cursor, " adversarys_offset=");
  cursor = AijinAppendSignalHex(cursor, pc - AijinDiagnosticAdversarysBase);
  cursor = AijinAppendSignalText(cursor, " lr=");
  cursor = AijinAppendSignalHex(cursor, lr);
  cursor = AijinAppendSignalText(cursor, " sp=");
  cursor = AijinAppendSignalHex(cursor, context->uc_mcontext->__ss.__sp);
  static const unsigned diagnosticRegisters[] = {
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
      12, 13, 17, 19, 20, 21, 22, 23, 24,
  };
  for (unsigned index = 0;
       index < sizeof(diagnosticRegisters) / sizeof(diagnosticRegisters[0]);
       index += 1) {
    unsigned registerIndex = diagnosticRegisters[index];
    cursor = AijinAppendSignalText(cursor, " x");
    if (registerIndex >= 10) {
      *cursor++ = (char)('0' + registerIndex / 10);
    }
    *cursor++ = (char)('0' + registerIndex % 10);
    *cursor++ = '=';
    cursor = AijinAppendSignalHex(
        cursor, context->uc_mcontext->__ss.__x[registerIndex]);
  }
  cursor = AijinAppendSignalText(cursor, " x25=");
  cursor = AijinAppendSignalHex(cursor, context->uc_mcontext->__ss.__x[25]);
  cursor = AijinAppendSignalText(cursor, " x26=");
  cursor = AijinAppendSignalHex(cursor, context->uc_mcontext->__ss.__x[26]);
  cursor = AijinAppendSignalText(cursor, " x27=");
  cursor = AijinAppendSignalHex(cursor, context->uc_mcontext->__ss.__x[27]);
  cursor = AijinAppendSignalText(cursor, " x28=");
  cursor = AijinAppendSignalHex(cursor, context->uc_mcontext->__ss.__x[28]);
  if (AijinDiagnosticWatchArmed && AijinDiagnosticWatchGuestState != 0) {
    const uintptr_t *watchedGuestRegisters =
        (const uintptr_t *)(AijinDiagnosticWatchGuestState + 0x40);
    cursor = AijinAppendSignalText(cursor, " watch_address=");
    cursor = AijinAppendSignalHex(cursor, AijinDiagnosticWatchAddress);
    for (unsigned guestIndex = 0; guestIndex < 8; guestIndex += 1) {
      cursor = AijinAppendSignalText(cursor, " watch_guest_x");
      *cursor++ = (char)('0' + guestIndex);
      *cursor++ = '=';
      cursor = AijinAppendSignalHex(
          cursor, watchedGuestRegisters[guestIndex]);
    }
    cursor = AijinAppendSignalText(cursor, " watch_guest_x30=");
    cursor = AijinAppendSignalHex(cursor, watchedGuestRegisters[30]);
    cursor = AijinAppendSignalText(cursor, " watch_guest_sp=");
    cursor = AijinAppendSignalHex(cursor, watchedGuestRegisters[31]);
    cursor = AijinAppendSignalText(cursor, " watch_guest_pc=");
    cursor = AijinAppendSignalHex(cursor, watchedGuestRegisters[32]);
  }
  if (adversarysOffset == 0x0088BC18 ||
      adversarysOffset == 0x0088BC70) {
    uintptr_t guestState = context->uc_mcontext->__ss.__x[14];
    const uintptr_t *guestRegisters =
        (const uintptr_t *)(guestState + 0x40);
    cursor = AijinAppendSignalText(cursor, " state=");
    cursor = AijinAppendSignalHex(cursor, guestState);
    cursor = AijinAppendSignalText(cursor, " guest_x0=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[0]);
    cursor = AijinAppendSignalText(cursor, " guest_x28=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[28]);
    cursor = AijinAppendSignalText(cursor, " guest_x29=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[29]);
    cursor = AijinAppendSignalText(cursor, " guest_x30=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[30]);
    cursor = AijinAppendSignalText(cursor, " guest_138=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[31]);
    cursor = AijinAppendSignalText(cursor, " guest_sp=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[32]);
    uintptr_t guestStack = guestRegisters[31];
    cursor = AijinAppendSignalText(cursor, " stack_word=");
    cursor = AijinAppendSignalHex(cursor, *(const uintptr_t *)guestStack);
  }
  if (adversarysOffset == 0x0088BC00) {
    const uintptr_t *guestRegisters =
        (const uintptr_t *)context->uc_mcontext->__ss.__x[11];
    cursor = AijinAppendSignalText(cursor, " guest_x0=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[0]);
    cursor = AijinAppendSignalText(cursor, " guest_x1=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[1]);
    cursor = AijinAppendSignalText(cursor, " guest_x28=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[28]);
    cursor = AijinAppendSignalText(cursor, " guest_x29=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[29]);
    cursor = AijinAppendSignalText(cursor, " guest_x30=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[30]);
    cursor = AijinAppendSignalText(cursor, " guest_sp=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[31]);
    cursor = AijinAppendSignalText(cursor, " guest_pc=");
    cursor = AijinAppendSignalHex(cursor, guestRegisters[32]);
  }
  uintptr_t runtimeObject = context->uc_mcontext->__ss.__x[0];
  if (pc == AijinDiagnosticAdversarysBase + 0x00008D38 &&
      runtimeObject != 0) {
    const uintptr_t *imageFields =
        (const uintptr_t *)(runtimeObject + 0xE0);
    cursor = AijinAppendSignalText(cursor, " image_e0=");
    cursor = AijinAppendSignalHex(cursor, imageFields[0]);
    cursor = AijinAppendSignalText(cursor, " image_e8=");
    cursor = AijinAppendSignalHex(cursor, imageFields[1]);
    cursor = AijinAppendSignalText(cursor, " image_f0=");
    cursor = AijinAppendSignalHex(cursor, imageFields[2]);
    cursor = AijinAppendSignalText(cursor, " image_f8=");
    cursor = AijinAppendSignalHex(cursor, imageFields[3]);
  }
  uintptr_t framePointer = context->uc_mcontext->__ss.__fp;
  cursor = AijinAppendSignalText(cursor, " x29=");
  cursor = AijinAppendSignalHex(cursor, framePointer);
  uintptr_t stackPointer = context->uc_mcontext->__ss.__sp;
  for (unsigned frameIndex = 0; frameIndex < 16; frameIndex += 1) {
    if (
        framePointer < stackPointer ||
        framePointer + 16 < framePointer ||
        framePointer + 16 > stackPointer + 0x400000 ||
        (framePointer & (sizeof(uintptr_t) - 1)) != 0
    ) {
      break;
    }
    const uintptr_t *frame = (const uintptr_t *)framePointer;
    uintptr_t previousFrame = frame[0];
    uintptr_t returnAddress = frame[1];
    cursor = AijinAppendSignalText(cursor, " frame");
    if (frameIndex >= 10) {
      *cursor++ = (char)('0' + frameIndex / 10);
    }
    *cursor++ = (char)('0' + frameIndex % 10);
    *cursor++ = '=';
    cursor = AijinAppendSignalHex(cursor, returnAddress);
    if (previousFrame <= framePointer) {
      break;
    }
    framePointer = previousFrame;
  }
  cursor = AijinAppendSignalText(cursor, " nivm_base=");
  uintptr_t nivmBase = 0;
  if (AijinDiagnosticAdversarysBase != 0) {
    nivmBase = *(const uintptr_t *)(AijinDiagnosticAdversarysBase + 0x62DE748);
  }
  cursor = AijinAppendSignalHex(cursor, nivmBase);
  *cursor++ = '\n';
  size_t length = (size_t)(cursor - buffer);
  write(STDERR_FILENO, buffer, length);
  if (AijinDiagnosticSignalFile >= 0) {
    write(AijinDiagnosticSignalFile, buffer, length);
  }
  _exit(128 + signalNumber);
}

static void AijinInstallDiagnosticSignalHandler(void) {
  if (AijinDiagnosticSignalHandlerInstalled) {
    return;
  }
  Dl_info imageInfo = {0};
  if (AijinAdversarysOpen != NULL &&
      dladdr((void *)AijinAdversarysOpen, &imageInfo) != 0) {
    AijinDiagnosticAdversarysBase = (uintptr_t)imageInfo.dli_fbase;
  }
  AijinDiagnosticDispatchOnceArmed =
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-dispatch-once"];
  NSURL *documentsURL = [NSFileManager.defaultManager
      URLsForDirectory:NSDocumentDirectory
      inDomains:NSUserDomainMask].lastObject;
  NSURL *signalURL =
      [documentsURL URLByAppendingPathComponent:@"aijin-runtime-signal.log"];
  AijinDiagnosticSignalFile = open(signalURL.fileSystemRepresentation,
                                    O_CREAT | O_WRONLY | O_TRUNC | O_APPEND,
                                    0600);
  struct sigaction action = {0};
  action.sa_sigaction = AijinDiagnosticSignalHandler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  sigaction(SIGILL, &action, NULL);
  sigaction(SIGTRAP, &action, NULL);
  sigaction(SIGSEGV, &action, NULL);
  sigaction(SIGBUS, &action, NULL);
  AijinDiagnosticSignalHandlerInstalled = YES;
}

static void AijinWriteDiagnosticStage(const char *stage) {
  if (AijinDiagnosticSignalFile >= 0 && stage != NULL) {
    dprintf(AijinDiagnosticSignalFile, "AIJIN_DIAGNOSTIC_STAGE %s\n", stage);
    fsync(AijinDiagnosticSignalFile);
  }
}

static void AijinLogDiagnosticMemory(NSString *stage) {
  task_vm_info_data_t info = {0};
  mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
  kern_return_t result = task_info(
      mach_task_self(), TASK_VM_INFO, (task_info_t)&info, &count);
  NSLog(@"AIJIN_DIAGNOSTIC_MEMORY stage=%@ kr=%d footprint=%llu "
         "resident=%llu virtual=%llu peak=%llu",
        stage, result, (unsigned long long)info.phys_footprint,
        (unsigned long long)info.resident_size,
        (unsigned long long)info.virtual_size,
        (unsigned long long)info.resident_size_peak);
}

static void AijinDiagnosticSampleHandler(int signalNumber,
                                          siginfo_t *signalInfo,
                                          void *rawContext) {
  (void)signalNumber;
  (void)signalInfo;
  ucontext_t *context = (ucontext_t *)rawContext;
  uintptr_t pc = context->uc_mcontext->__ss.__pc;
  uintptr_t runtimeOffset = pc - AijinDiagnosticAdversarysBase;
  uintptr_t fuelCursor = context->uc_mcontext->__ss.__x[28];
  if (AijinDiagnosticSampleCount >= AijinDiagnosticSampleLimit ||
      AijinDiagnosticAdversarysBase == 0 ||
      runtimeOffset < 0x20000 || runtimeOffset >= 0x6258000 ||
      fuelCursor < 0x100000000) {
    return;
  }
  AijinDiagnosticSampleCount += 1;
  const uintptr_t *fuel = (const uintptr_t *)fuelCursor;
  char buffer[1024];
  char *cursor = AijinAppendSignalText(
      buffer, "AIJIN_DIAGNOSTIC_SAMPLE handler=");
  cursor = AijinAppendSignalHex(cursor, runtimeOffset);
  cursor = AijinAppendSignalText(cursor, " fuel_cursor=");
  cursor = AijinAppendSignalHex(cursor, fuelCursor);
  cursor = AijinAppendSignalText(cursor, " q-2=");
  cursor = AijinAppendSignalHex(cursor, fuel[-2]);
  cursor = AijinAppendSignalText(cursor, " q-1=");
  cursor = AijinAppendSignalHex(cursor, fuel[-1]);
  cursor = AijinAppendSignalText(cursor, " q0=");
  cursor = AijinAppendSignalHex(cursor, fuel[0]);
  cursor = AijinAppendSignalText(cursor, " q1=");
  cursor = AijinAppendSignalHex(cursor, fuel[1]);
  *cursor++ = '\n';
  write(STDERR_FILENO, buffer, (size_t)(cursor - buffer));
}

static void AijinInstallDiagnosticSampler(void) {
  struct sigaction action = {0};
  action.sa_sigaction = AijinDiagnosticSampleHandler;
  action.sa_flags = SA_SIGINFO | SA_RESTART;
  sigemptyset(&action.sa_mask);
  sigaction(SIGPROF, &action, NULL);
  struct itimerval timer = {0};
  timer.it_value.tv_usec = 100000;
  timer.it_interval.tv_usec = 100000;
  setitimer(ITIMER_PROF, &timer, NULL);
}

static void AijinSampleAdversarysThreads(void) {
  thread_act_array_t threads = NULL;
  mach_msg_type_number_t threadCount = 0;
  if (task_threads(mach_task_self(), &threads, &threadCount) != KERN_SUCCESS) {
    return;
  }
  mach_port_t samplerThread = mach_thread_self();
  for (mach_msg_type_number_t index = 0;
       index < threadCount &&
           AijinDiagnosticSampleCount < AijinDiagnosticSampleLimit;
       index += 1) {
    thread_t thread = threads[index];
    if (thread == samplerThread || thread_suspend(thread) != KERN_SUCCESS) {
      continue;
    }
    arm_thread_state64_t state = {0};
    mach_msg_type_number_t stateCount = ARM_THREAD_STATE64_COUNT;
    kern_return_t result = thread_get_state(
        thread, ARM_THREAD_STATE64, (thread_state_t)&state, &stateCount);
    uintptr_t pc = result == KERN_SUCCESS ? arm_thread_state64_get_pc(state) : 0;
    uintptr_t lr = result == KERN_SUCCESS ? arm_thread_state64_get_lr(state) : 0;
    uintptr_t runtimeOffset = pc - AijinDiagnosticAdversarysBase;
    uintptr_t fuelCursor = result == KERN_SUCCESS
        ? state.__x[28]
        : 0;
    uintptr_t runtimeRegister = result == KERN_SUCCESS
        ? state.__x[26]
        : 0;
    uintptr_t qMinus2 = 0;
    uintptr_t qMinus1 = 0;
    uintptr_t qZero = 0;
    uintptr_t qOne = 0;
    BOOL shouldLog = result == KERN_SUCCESS &&
        AijinDiagnosticAdversarysBase != 0 &&
        runtimeRegister == AijinDiagnosticAdversarysBase &&
        fuelCursor >= 0x100000000;
    if (shouldLog) {
      const uintptr_t *fuel = (const uintptr_t *)fuelCursor;
      qMinus2 = fuel[-2];
      qMinus1 = fuel[-1];
      qZero = fuel[0];
      qOne = fuel[1];
    }
    thread_resume(thread);
    if (!shouldLog) {
      continue;
    }
    AijinDiagnosticSampleCount += 1;
    char buffer[1024];
    char *cursor = AijinAppendSignalText(
        buffer, "AIJIN_DIAGNOSTIC_THREAD_SAMPLE pc=");
    cursor = AijinAppendSignalHex(cursor, pc);
    cursor = AijinAppendSignalText(cursor, " lr=");
    cursor = AijinAppendSignalHex(cursor, lr);
    cursor = AijinAppendSignalText(cursor, " handler=");
    cursor = AijinAppendSignalHex(cursor, runtimeOffset);
    cursor = AijinAppendSignalText(cursor, " fuel_cursor=");
    cursor = AijinAppendSignalHex(cursor, fuelCursor);
    cursor = AijinAppendSignalText(cursor, " q-2=");
    cursor = AijinAppendSignalHex(cursor, qMinus2);
    cursor = AijinAppendSignalText(cursor, " q-1=");
    cursor = AijinAppendSignalHex(cursor, qMinus1);
    cursor = AijinAppendSignalText(cursor, " q0=");
    cursor = AijinAppendSignalHex(cursor, qZero);
    cursor = AijinAppendSignalText(cursor, " q1=");
    cursor = AijinAppendSignalHex(cursor, qOne);
    *cursor++ = '\n';
    write(STDERR_FILENO, buffer, (size_t)(cursor - buffer));
  }
  mach_port_deallocate(mach_task_self(), samplerThread);
  vm_deallocate(mach_task_self(), (vm_address_t)threads,
                threadCount * sizeof(thread_t));
}

static unsigned int AijinSampleAdversarysThreadsToFile(FILE *output,
                                                         unsigned int ordinal) {
  thread_act_array_t threads = NULL;
  mach_msg_type_number_t threadCount = 0;
  if (task_threads(mach_task_self(), &threads, &threadCount) != KERN_SUCCESS) {
    return 0;
  }
  mach_port_t samplerThread = mach_thread_self();
  unsigned int hits = 0;
  for (mach_msg_type_number_t index = 0; index < threadCount; index += 1) {
    thread_t thread = threads[index];
    if (thread == samplerThread || thread_suspend(thread) != KERN_SUCCESS) {
      continue;
    }
    arm_thread_state64_t state = {0};
    mach_msg_type_number_t stateCount = ARM_THREAD_STATE64_COUNT;
    kern_return_t stateResult = thread_get_state(
        thread, ARM_THREAD_STATE64, (thread_state_t)&state, &stateCount);
    thread_resume(thread);
    if (stateResult != KERN_SUCCESS) {
      continue;
    }
    uintptr_t pc = arm_thread_state64_get_pc(state);
    uintptr_t runtimeRegister = state.__x[26];
    uintptr_t fuelCursor = state.__x[28];
    uintptr_t imageBase = state.__x[17];
    uintptr_t guestRegisterBase = state.__x[11];
    uintptr_t hostX0 = state.__x[0];
    uintptr_t guestX8 = 0;
    uintptr_t guestX19 = 0;
    uint64_t flutterConstProbe[2] = {0, 0};
    vm_size_t flutterConstProbeSize = 0;
    kern_return_t flutterConstProbeResult = KERN_INVALID_ADDRESS;
    if (AijinDiagnosticAdversarysBase == 0 ||
        runtimeRegister != AijinDiagnosticAdversarysBase ||
        fuelCursor < 0x100000000) {
      continue;
    }
    if (guestRegisterBase >= 0x100000000) {
      const uintptr_t *guestRegisters =
          (const uintptr_t *)guestRegisterBase;
      guestX8 = guestRegisters[8];
      guestX19 = guestRegisters[19];
    }
    if (imageBase >= 0x100000000) {
      flutterConstProbeResult = vm_read_overwrite(
          mach_task_self(), (vm_address_t)(imageBase + 0x776fd0),
          sizeof(flutterConstProbe),
          (vm_address_t)flutterConstProbe,
          &flutterConstProbeSize);
    }
    const uintptr_t *fuel = (const uintptr_t *)fuelCursor;
    fprintf(output,
            "%u 0x%llx 0x%llx 0x%llx 0x%llx 0x%llx 0x%llx %u "
            "image=0x%llx regs=0x%llx host_x0=0x%llx "
            "guest_x8=0x%llx guest_x19=0x%llx "
            "flutter_const_kr=%d size=0x%llx data=0x%llx,0x%llx\n",
            ordinal, (unsigned long long)pc,
            (unsigned long long)fuelCursor,
            (unsigned long long)fuel[-2],
            (unsigned long long)fuel[-1],
            (unsigned long long)fuel[0],
            (unsigned long long)fuel[1], thread,
            (unsigned long long)imageBase,
            (unsigned long long)guestRegisterBase,
            (unsigned long long)hostX0,
            (unsigned long long)guestX8,
            (unsigned long long)guestX19,
            flutterConstProbeResult,
            (unsigned long long)flutterConstProbeSize,
            (unsigned long long)flutterConstProbe[0],
            (unsigned long long)flutterConstProbe[1]);
    hits += 1;
  }
  mach_port_deallocate(mach_task_self(), samplerThread);
  vm_deallocate(mach_task_self(), (vm_address_t)threads,
                threadCount * sizeof(thread_t));
  return hits;
}

static void AijinStartDiagnosticFileBurst(NSString *reason) {
  if (![NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-result-file-burst"] ||
      !__sync_bool_compare_and_swap(&AijinDiagnosticFileBurstStarted, 0, 1)) {
    return;
  }
  NSString *reasonCopy = [reason copy];
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    @autoreleasepool {
      NSURL *documentsURL = [NSFileManager.defaultManager
          URLsForDirectory:NSDocumentDirectory
          inDomains:NSUserDomainMask].lastObject;
      NSURL *outputURL =
          [documentsURL URLByAppendingPathComponent:@"aijin-runtime-fuel.log"];
      FILE *output = fopen(outputURL.fileSystemRepresentation, "w");
      if (output == NULL) {
        NSLog(@"AIJIN_DIAGNOSTIC_FILE_BURST open_failed path=%@ errno=%d",
              outputURL.path, errno);
        return;
      }
      // The guest runtime may terminate the process with _exit(), which skips
      // stdio flushing.  Keep every sampled fuel cursor durable as it is
      // collected so the last translated block remains available afterward.
      setvbuf(output, NULL, _IONBF, 0);
      fprintf(output, "ADVERSARYS_BASE 0x%llx REASON %s\n",
              (unsigned long long)AijinDiagnosticAdversarysBase,
              reasonCopy.UTF8String ?: "");
      unsigned int hits = 0;
      for (unsigned int ordinal = 0; ordinal < 14000; ordinal += 1) {
        hits += AijinSampleAdversarysThreadsToFile(output, ordinal);
        usleep(500);
      }
      fprintf(output, "DONE samples=14000 hits=%u\n", hits);
      fclose(output);
      NSLog(@"AIJIN_DIAGNOSTIC_FILE_BURST end hits=%u path=%@", hits,
            outputURL.path);
    }
  });
}

static void AijinStartDiagnosticFocusedBurst(void) {
  if (!__sync_bool_compare_and_swap(&AijinDiagnosticFocusedBurstStarted,
                                    0, 1)) {
    return;
  }
  thread_t targetThread = mach_thread_self();
  dispatch_semaphore_t ready = dispatch_semaphore_create(0);
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
    @autoreleasepool {
      NSURL *documentsURL = [NSFileManager.defaultManager
          URLsForDirectory:NSDocumentDirectory
          inDomains:NSUserDomainMask].lastObject;
      NSURL *outputURL = [documentsURL
          URLByAppendingPathComponent:@"aijin-runtime-focused.log"];
      FILE *output = fopen(outputURL.fileSystemRepresentation, "w");
      if (output == NULL) {
        dispatch_semaphore_signal(ready);
        mach_port_deallocate(mach_task_self(), targetThread);
        return;
      }
      setvbuf(output, NULL, _IONBF, 0);
      fprintf(output, "ADVERSARYS_BASE 0x%llx THREAD %u\n",
              (unsigned long long)AijinDiagnosticAdversarysBase,
              targetThread);
      dispatch_semaphore_signal(ready);
      // Tianya can terminate during the first translated instructions after
      // guest_main_start.  Begin sampling immediately so the durable trace
      // retains the last main-thread Fuel cursor before an uncatchable kill.
      usleep(0);
      unsigned int hits = 0;
      for (unsigned int ordinal = 0;
           ordinal < 600000 && hits < 60000;
           ordinal++) {
        arm_thread_state64_t state = {0};
        mach_msg_type_number_t stateCount = ARM_THREAD_STATE64_COUNT;
        if (thread_suspend(targetThread) != KERN_SUCCESS) {
          continue;
        }
        kern_return_t stateResult = thread_get_state(
            targetThread, ARM_THREAD_STATE64, (thread_state_t)&state,
            &stateCount);
        thread_resume(targetThread);
        if (stateResult != KERN_SUCCESS) {
          continue;
        }
        uintptr_t pc = arm_thread_state64_get_pc(state);
        uintptr_t runtimeRegister = state.__x[26];
        uintptr_t fuelCursor = state.__x[28];
        if (AijinDiagnosticAdversarysBase == 0 ||
            runtimeRegister != AijinDiagnosticAdversarysBase ||
            fuelCursor < 0x100000000) {
          usleep(50);
          continue;
        }
        uintptr_t nivmBase = *(const uintptr_t *)(
            AijinDiagnosticAdversarysBase + 0x62DE748);
        fprintf(output,
                "%u pc=0x%llx fuel_cursor=0x%llx nivm_base=0x%llx\n",
                ordinal, (unsigned long long)pc,
                (unsigned long long)fuelCursor,
                (unsigned long long)nivmBase);
        hits++;
        usleep(100);
      }
      fprintf(output, "DONE attempts=600000 hits=%u\n", hits);
      fclose(output);
      mach_port_deallocate(mach_task_self(), targetThread);
      NSLog(@"AIJIN_DIAGNOSTIC_FOCUSED end hits=%u path=%@", hits,
            outputURL.path);
    }
  });
  dispatch_semaphore_wait(ready,
                          dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
}

static void AijinScheduleDiagnosticThreadSampler(void) {
  dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
  dispatch_source_t timer = dispatch_source_create(
      DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  dispatch_source_set_timer(
      timer, dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC),
      10 * NSEC_PER_MSEC, 2 * NSEC_PER_MSEC);
  dispatch_source_set_event_handler(timer, ^{
    AijinSampleAdversarysThreads();
    if (AijinDiagnosticSampleCount >= AijinDiagnosticSampleLimit) {
      dispatch_source_cancel(timer);
    }
  });
  dispatch_resume(timer);
}

static NSString *const AijinGuestModeKey = @"TempMailPlayBoxGuestMode";
static NSString *const AijinGuestLaunchTokenKey = @"TempMailPlayBoxGuestLaunchToken";
static NSString *const AijinGuestBundleKey = @"TempMailPlayBoxGuestBundle";
static NSString *const AijinGuestExecutableKey = @"TempMailPlayBoxGuestExecutable";
static NSString *const AijinGuestNIVMKey = @"TempMailPlayBoxGuestNIVM";
static NSString *const AijinRuntimeKindKey = @"TempMailGuestRuntimeKind";
static NSString *const AijinRuntimeLaunchTokenKey = @"TempMailGuestLaunchToken";
static NSString *const AijinPlayBoxContinuationMarker =
    @"TempMailTest/playbox-relaunch-continuation";

static NSURL *AijinPlayBoxContinuationMarkerURL(void) {
  NSURL *documentsURL = [NSFileManager.defaultManager
      URLsForDirectory:NSDocumentDirectory
      inDomains:NSUserDomainMask].lastObject;
  return [documentsURL URLByAppendingPathComponent:
      AijinPlayBoxContinuationMarker];
}

static BOOL AijinConsumeFreshPlayBoxContinuationMarker(void) {
  NSURL *markerURL = AijinPlayBoxContinuationMarkerURL();
  NSDictionary<NSFileAttributeKey, id> *attributes =
      [NSFileManager.defaultManager attributesOfItemAtPath:markerURL.path
                                                    error:nil];
  NSDate *modified = attributes[NSFileModificationDate];
  if (modified == nil) {
    return NO;
  }
  NSTimeInterval age = -modified.timeIntervalSinceNow;
  [NSFileManager.defaultManager removeItemAtURL:markerURL error:nil];
  if (age < 0 || age > 180) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME continuation_ignored age=%.1f", age);
    return NO;
  }
  NSLog(@"AIJIN_PLAYBOX_RUNTIME continuation_consumed age=%.1f", age);
  return YES;
}

@class AijinGuestFloatingControl;

@interface AijinFloatingMenuView : UIView
@property(nonatomic, strong) UIView *coverView;
@property(nonatomic, strong) UIControl *actionButton;
@property(nonatomic, strong) UIImageView *actionIconView;
@property(nonatomic, strong) UILabel *actionTitleLabel;
@property(nonatomic, weak) AijinGuestFloatingControl *sourceControl;
- (void)displayFromControl:(AijinGuestFloatingControl *)control
                    inView:(UIView *)container
                  animated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
@end

@interface AijinGuestFloatingControl : UIControl
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic) CGPoint dragStartCenter;
- (void)showMenuAnimated:(BOOL)animated;
@end

static AijinGuestFloatingControl *AijinGuestFloatingView;
static AijinFloatingMenuView *AijinGuestFloatingMenuView;
static BOOL AijinFloatingReturnInFlight;
static BOOL AijinFloatingHasStoredPosition;
static BOOL AijinFloatingDockedToLeft;
static CGFloat AijinFloatingStoredYRatio = 0.5;
static const CGFloat AijinFloatingActionSize = 82;

static NSBundle *AijinPlayBoxFloatingBundle(void) {
  NSBundle *hostBundle = AijinHostBundle;
  if (hostBundle == nil) {
    hostBundle = [NSBundle bundleForClass:AijinGuestFloatingControl.class];
  }
  NSString *path = [hostBundle.bundlePath
      stringByAppendingPathComponent:
          @"Frameworks/PBPlayerKit.framework/Floating.bundle"];
  return [NSBundle bundleWithPath:path];
}

static UIImage *AijinFloatingImage(NSString *name) {
  return [UIImage imageNamed:name
                    inBundle:AijinPlayBoxFloatingBundle()
       compatibleWithTraitCollection:nil];
}

static NSString *AijinFloatingLocalizedString(NSString *key,
                                                NSString *fallback) {
  NSBundle *bundle = AijinPlayBoxFloatingBundle();
  NSString *value = [bundle localizedStringForKey:key
                                             value:fallback
                                             table:@"PBPlayerFramework"];
  return value.length > 0 ? value : fallback;
}

static void AijinReturnToSandbox(void) {
  if (AijinFloatingReturnInFlight) {
    return;
  }
  AijinFloatingReturnInFlight = YES;
  NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
  [defaults removeObjectForKey:AijinRuntimeLaunchTokenKey];
  [defaults removeObjectForKey:AijinGuestLaunchTokenKey];
  [defaults removeObjectForKey:AijinGuestModeKey];
  [defaults synchronize];
  [NSFileManager.defaultManager
      removeItemAtURL:AijinPlayBoxContinuationMarkerURL()
                error:nil];

  NSURL *relaunchURL = [NSURL URLWithString:
      @"tempmail://sandbox.relaunch"];
  NSLog(@"AIJIN_FLOATING_RETURN requested url=%@", relaunchURL);
  void (^completion)(BOOL) = ^(BOOL accepted) {
    NSLog(@"AIJIN_FLOATING_RETURN accepted=%d", accepted);
    if (!accepted) {
      AijinFloatingReturnInFlight = NO;
      return;
    }
    [UIApplication.sharedApplication performSelector:NSSelectorFromString(@"suspend")];
    // Guest atexit hooks can point into translated pages; skip destructors.
    _exit(0);
  };
  [UIApplication.sharedApplication openURL:relaunchURL
                                   options:@{}
                         completionHandler:completion];
  [UIApplication.sharedApplication openURL:relaunchURL
                                   options:@{}
                         completionHandler:completion];
}

@implementation AijinFloatingMenuView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self == nil) {
    return nil;
  }
  self.accessibilityViewIsModal = YES;

  _coverView = [[UIView alloc] initWithFrame:self.bounds];
  _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleHeight;
  // PlayBox deliberately keeps the cover visually transparent while using it
  // to intercept taps outside the menu (alpha 0.01 in FloatingCore).
  _coverView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.01];
  UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(handleCoverTap)];
  [_coverView addGestureRecognizer:dismissTap];
  [self addSubview:_coverView];

  _actionButton = [[UIControl alloc]
      initWithFrame:CGRectMake(0, 0, AijinFloatingActionSize,
                               AijinFloatingActionSize)];
  _actionButton.accessibilityIdentifier = @"aijin.return-to-ai.action";
  _actionButton.accessibilityLabel = AijinFloatingLocalizedString(
      @"floating_back_app_title", @"返回沙盒");
  _actionButton.backgroundColor =
      [UIColor.blackColor colorWithAlphaComponent:0.84];
  _actionButton.layer.cornerRadius = 11;
  _actionButton.layer.borderWidth = 0.5;
  _actionButton.layer.borderColor =
      [UIColor.whiteColor colorWithAlphaComponent:0.10].CGColor;
  [_actionButton addTarget:self
                    action:@selector(handleActionTap)
          forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:_actionButton];

  _actionIconView = [[UIImageView alloc] initWithImage:
      AijinFloatingImage(@"cscb_floating_back_icon")];
  _actionIconView.contentMode = UIViewContentModeScaleAspectFit;
  _actionIconView.userInteractionEnabled = NO;
  [_actionButton addSubview:_actionIconView];

  _actionTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  _actionTitleLabel.text = AijinFloatingLocalizedString(
      @"floating_back_app_title", @"返回沙盒");
  _actionTitleLabel.textColor = UIColor.whiteColor;
  _actionTitleLabel.font = [UIFont systemFontOfSize:12
                                            weight:UIFontWeightRegular];
  _actionTitleLabel.textAlignment = NSTextAlignmentCenter;
  _actionTitleLabel.userInteractionEnabled = NO;
  [_actionButton addSubview:_actionTitleLabel];
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.coverView.frame = self.bounds;
  self.actionIconView.frame = CGRectMake(27, 13, 28, 28);
  self.actionTitleLabel.frame = CGRectMake(4, 46, 74, 17);
}

- (CGRect)targetFrameForControl:(AijinGuestFloatingControl *)control
                      container:(UIView *)container {
  CGRect sourceFrame = [control.superview convertRect:control.frame
                                                toView:container];
  CGFloat x = CGRectGetMidX(sourceFrame) - AijinFloatingActionSize / 2.0;
  CGFloat y = CGRectGetMidY(sourceFrame) - AijinFloatingActionSize / 2.0;
  x = MIN(MAX(x, 16), CGRectGetWidth(container.bounds) -
                              AijinFloatingActionSize - 16);
  return CGRectMake(x, y, AijinFloatingActionSize,
                    AijinFloatingActionSize);
}

- (void)displayFromControl:(AijinGuestFloatingControl *)control
                    inView:(UIView *)container
                  animated:(BOOL)animated {
  self.sourceControl = control;
  self.frame = container.bounds;
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleHeight;
  [container addSubview:self];

  CGRect sourceFrame = [control.superview convertRect:control.frame
                                                toView:self];
  CGRect targetFrame = [self targetFrameForControl:control container:self];
  self.actionButton.frame = targetFrame;
  [self setNeedsLayout];
  [self layoutIfNeeded];
  if (!animated) {
    self.actionButton.transform = CGAffineTransformIdentity;
    return;
  }

  CGFloat sourceScale = CGRectGetWidth(sourceFrame) /
      CGRectGetWidth(targetFrame);
  CGAffineTransform scale = CGAffineTransformMakeScale(sourceScale,
                                                       sourceScale);
  CGFloat dx = CGRectGetMidX(sourceFrame) - CGRectGetMidX(targetFrame);
  CGFloat dy = CGRectGetMidY(sourceFrame) - CGRectGetMidY(targetFrame);
  self.actionButton.transform = CGAffineTransformConcat(
      scale, CGAffineTransformMakeTranslation(dx / sourceScale,
                                              dy / sourceScale));
  [UIView animateWithDuration:0.25 animations:^{
    self.actionButton.transform = CGAffineTransformIdentity;
  }];
}

- (void)hideAnimated:(BOOL)animated {
  AijinGuestFloatingControl *control = self.sourceControl;
  if (!animated || control.superview == nil) {
    [self removeFromSuperview];
    AijinGuestFloatingMenuView = nil;
    return;
  }
  CGRect sourceFrame = [control.superview convertRect:control.frame
                                                toView:self];
  CGRect targetFrame = self.actionButton.frame;
  CGFloat sourceScale = CGRectGetWidth(sourceFrame) /
      CGRectGetWidth(targetFrame);
  CGFloat dx = CGRectGetMidX(sourceFrame) - CGRectGetMidX(targetFrame);
  CGFloat dy = CGRectGetMidY(sourceFrame) - CGRectGetMidY(targetFrame);
  CGAffineTransform transform = CGAffineTransformConcat(
      CGAffineTransformMakeScale(sourceScale, sourceScale),
      CGAffineTransformMakeTranslation(dx / sourceScale,
                                       dy / sourceScale));
  [UIView animateWithDuration:0.25
                   animations:^{ self.actionButton.transform = transform; }
                   completion:^(__unused BOOL finished) {
    [self removeFromSuperview];
    AijinGuestFloatingMenuView = nil;
  }];
}

- (void)handleCoverTap {
  [self hideAnimated:YES];
}

- (void)handleActionTap {
  AijinReturnToSandbox();
}

@end

@implementation AijinGuestFloatingControl

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self == nil) {
    return nil;
  }
  self.accessibilityIdentifier = @"aijin.return-to-ai";
  self.accessibilityLabel = AijinFloatingLocalizedString(
      @"floating_back_app_title", @"返回沙盒");

  _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
  _iconView.contentMode = UIViewContentModeScaleAspectFit;
  _iconView.image = AijinFloatingImage(@"cscb_floating_icon");
  _iconView.highlightedImage =
      AijinFloatingImage(@"cscb_floating_icon_highlight");
  if (_iconView.image == nil) {
    _iconView.image = [UIImage systemImageNamed:@"shippingbox.fill"];
    _iconView.tintColor = UIColor.whiteColor;
    _iconView.backgroundColor = [UIColor colorWithRed:0.16
                                                green:0.23
                                                 blue:0.43
                                                alpha:0.96];
    _iconView.layer.cornerRadius = 30;
  }
  _iconView.userInteractionEnabled = NO;
  [self addSubview:_iconView];

  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
      initWithTarget:self action:@selector(handlePan:)];
  pan.minimumNumberOfTouches = 1;
  pan.maximumNumberOfTouches = 1;
  pan.cancelsTouchesInView = YES;
  [self addGestureRecognizer:pan];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(handleTap:)];
  tap.cancelsTouchesInView = YES;
  [tap requireGestureRecognizerToFail:pan];
  [self addGestureRecognizer:tap];
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.iconView.frame = self.bounds;
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  self.iconView.highlighted = highlighted;
}

- (void)handleTap:(__unused UITapGestureRecognizer *)tap {
  [self showMenuAnimated:YES];
}

- (BOOL)accessibilityActivate {
  [self showMenuAnimated:YES];
  return YES;
}

- (void)showMenuAnimated:(BOOL)animated {
  UIView *container = self.superview;
  if (container == nil || AijinGuestFloatingMenuView.superview != nil) {
    return;
  }
  AijinFloatingMenuView *menu = [[AijinFloatingMenuView alloc]
      initWithFrame:container.bounds];
  AijinGuestFloatingMenuView = menu;
  [menu displayFromControl:self inView:container animated:animated];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
  UIView *container = self.superview;
  if (container == nil) {
    return;
  }

  UIEdgeInsets safe = container.safeAreaInsets;
  CGFloat halfWidth = CGRectGetWidth(self.bounds) / 2.0;
  CGFloat halfHeight = CGRectGetHeight(self.bounds) / 2.0;
  CGFloat left = safe.left + 8 + halfWidth;
  CGFloat right = MAX(left, CGRectGetWidth(container.bounds) - safe.right - 8 - halfWidth);
  CGFloat top = safe.top + 18 + halfHeight;
  CGFloat bottom = MAX(top, CGRectGetHeight(container.bounds) - safe.bottom - 18 - halfHeight);

  if (pan.state == UIGestureRecognizerStateBegan) {
    self.dragStartCenter = self.center;
    self.highlighted = YES;
    [UIView animateWithDuration:0.12 animations:^{
      self.transform = CGAffineTransformMakeScale(0.94, 0.94);
    }];
    return;
  }

  if (pan.state == UIGestureRecognizerStateChanged) {
    CGPoint translation = [pan translationInView:container];
    CGPoint center = CGPointMake(self.dragStartCenter.x + translation.x,
                                 self.dragStartCenter.y + translation.y);
    center.x = MIN(MAX(center.x, left), right);
    center.y = MIN(MAX(center.y, top), bottom);
    self.center = center;
    return;
  }

  if (pan.state != UIGestureRecognizerStateEnded &&
      pan.state != UIGestureRecognizerStateCancelled &&
      pan.state != UIGestureRecognizerStateFailed) {
    return;
  }

  CGPoint velocity = [pan velocityInView:container];
  CGPoint target = self.center;
  if (pan.state == UIGestureRecognizerStateEnded) {
    target.x += velocity.x * 0.10;
    target.y += velocity.y * 0.10;
  }
  AijinFloatingDockedToLeft = target.x < CGRectGetMidX(container.bounds);
  target.x = AijinFloatingDockedToLeft ? left : right;
  target.y = MIN(MAX(target.y, top), bottom);
  AijinFloatingStoredYRatio = bottom > top
      ? (target.y - top) / (bottom - top)
      : 0.5;
  AijinFloatingHasStoredPosition = YES;
  self.highlighted = NO;
  [UIView animateWithDuration:0.28
                        delay:0
       usingSpringWithDamping:0.82
        initialSpringVelocity:0.25
                      options:UIViewAnimationOptionBeginFromCurrentState |
                              UIViewAnimationOptionAllowUserInteraction
                   animations:^{
    self.center = target;
    self.transform = CGAffineTransformIdentity;
  }
                   completion:nil];
}

@end

static void AijinInstallGuestFloatingControl(UIWindow *window) {
  if (window == nil) {
    return;
  }
  [AijinGuestFloatingMenuView removeFromSuperview];
  AijinGuestFloatingMenuView = nil;
  [AijinGuestFloatingView removeFromSuperview];
  CGFloat size = 60;
  UIEdgeInsets safe = window.safeAreaInsets;
  CGFloat halfSize = size / 2.0;
  CGFloat left = safe.left + 8 + halfSize;
  CGFloat right = MAX(left, CGRectGetWidth(window.bounds) - safe.right - 8 - halfSize);
  CGFloat top = safe.top + 18 + halfSize;
  CGFloat bottom = MAX(top, CGRectGetHeight(window.bounds) - safe.bottom - 18 - halfSize);
  CGFloat x = AijinFloatingHasStoredPosition
      ? (AijinFloatingDockedToLeft ? left : right)
      : right;
  CGFloat defaultY = MAX(safe.top + 82 + halfSize,
                         CGRectGetHeight(window.bounds) * 0.48 + halfSize);
  CGFloat y = AijinFloatingHasStoredPosition
      ? top + AijinFloatingStoredYRatio * (bottom - top)
      : MIN(defaultY, bottom);
  AijinGuestFloatingControl *control =
      [[AijinGuestFloatingControl alloc]
          initWithFrame:CGRectMake(x - halfSize, y - halfSize, size, size)];
  control.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
      UIViewAutoresizingFlexibleTopMargin;
  [window addSubview:control];
  [window bringSubviewToFront:control];
  AijinGuestFloatingView = control;
  NSLog(@"AIJIN_FLOATING_RETURN installed window=%@ asset=%d",
        NSStringFromClass(window.class), control.iconView.image != nil);
  NSURL *qaReturnMarker = [AijinPlayBoxContinuationMarkerURL().URLByDeletingLastPathComponent
      URLByAppendingPathComponent:@"qa-floating-return"];
  NSUserDefaults *qaDefaults = NSUserDefaults.standardUserDefaults;
  if ([NSProcessInfo.processInfo.arguments containsObject:@"--aijin-test-floating-return"] ||
      [qaDefaults boolForKey:@"TempMailQAFloatingReturn"] ||
      [NSFileManager.defaultManager fileExistsAtPath:qaReturnMarker.path]) {
    [NSFileManager.defaultManager removeItemAtURL:qaReturnMarker error:nil];
    [qaDefaults removeObjectForKey:@"TempMailQAFloatingReturn"];
    [qaDefaults synchronize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(15.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
      [control showMenuAnimated:NO];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                   (int64_t)(4.0 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
        AijinReturnToSandbox();
      });
    });
  }
}

static void *AijinLoadFramework(NSString *name) {
  NSString *path = [NSBundle.mainBundle.privateFrameworksPath
      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.framework/%@", name, name]];
  void *handle = dlopen(path.fileSystemRepresentation, RTLD_NOW | RTLD_GLOBAL);
  if (handle == NULL) {
    NSLog(@"AIJIN_RUNTIME framework_load_failed name=%@ error=%s", name, dlerror());
  } else {
    NSLog(@"AIJIN_RUNTIME framework_loaded name=%@", name);
  }
  return handle;
}

static BOOL AijinLoadPlayBoxRuntime(void) {
  void *player = AijinLoadFramework(@"PBPlayerKit");
  void *runtime = AijinLoadFramework(@"adversarys");
  if (player == NULL || runtime == NULL) {
    return NO;
  }
  // Save the host Kiwi class before a guest with its own statically linked
  // class is loaded and Objective-C reports a duplicate name.
  AijinNativeKiwiClass = NSClassFromString(@"Kiwi");

  AijinNUDGuestHooksInit = dlsym(player, "NUDGuestHooksInit");
  AijinPBPlayerSetupApp = dlsym(
      player, "_$s11PBPlayerKit0aB3BoxV8setupAppyyFZ");
  AijinAdversarysOpen = dlsym(runtime, "adversarys_0_ex");
  AijinAdversarysOpenLoose = dlsym(runtime, "adversarys_0");
  AijinAdversarysSymbol = dlsym(runtime, "adversarys_1");
  AijinAdversarysError = dlsym(runtime, "adversarys_2");
  AijinAdversarysClass = dlsym(runtime, "adversarys_4");
  AijinAdversarysAbort = dlsym(runtime, "adversarys_b");
  AijinAdversarysHandler = dlsym(runtime, "adversarys_d");
  Dl_info runtimeInfo = {0};
  if (AijinAdversarysOpen != NULL &&
      dladdr((void *)AijinAdversarysOpen, &runtimeInfo) != 0) {
    AijinDiagnosticAdversarysBase = (uintptr_t)runtimeInfo.dli_fbase;
  }
  void *defaultMainLoop = dlsym(RTLD_DEFAULT, "AijinEnterGuestMainLoop");
  void *mainOnlyMainLoop = dlsym(RTLD_MAIN_ONLY, "AijinEnterGuestMainLoop");
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_main_loop_symbol default=%p main=%p",
        defaultMainLoop, mainOnlyMainLoop);
  return AijinNUDGuestHooksInit != NULL && AijinAdversarysOpen != NULL &&
      AijinAdversarysOpenLoose != NULL &&
      AijinAdversarysSymbol != NULL && AijinAdversarysError != NULL &&
      AijinAdversarysClass != NULL && AijinAdversarysAbort != NULL &&
      AijinAdversarysHandler != NULL;
}

static UITableView *AijinFindTableView(UIView *view) {
  if ([view isKindOfClass:UITableView.class]) {
    return (UITableView *)view;
  }
  for (UIView *subview in view.subviews) {
    UITableView *tableView = AijinFindTableView(subview);
    if (tableView != nil) {
      return tableView;
    }
  }
  return nil;
}

static void AijinCollectViewText(UIView *view,
                                  NSMutableArray<NSString *> *texts) {
  if ([view isKindOfClass:UILabel.class]) {
    NSString *text = ((UILabel *)view).text;
    if (text.length > 0) {
      [texts addObject:text];
    }
  }
  for (UIView *subview in view.subviews) {
    AijinCollectViewText(subview, texts);
  }
}

@interface AijinPlayBoxDeveloperDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
@end

@implementation AijinPlayBoxDeveloperDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if (!AijinLoadPlayBoxRuntime()) {
    NSLog(@"AIJIN_PLAYBOX_DEVELOPER boot_failed reason=runtime_load");
    return NO;
  }
  if (AijinPBPlayerSetupApp != NULL) {
    AijinPBPlayerSetupApp();
  }

  Class controllerClass =
      NSClassFromString(@"PBPlayerKit.DeveloperController");
  if (controllerClass == Nil) {
    controllerClass = NSClassFromString(
        @"_TtC11PBPlayerKit19DeveloperController");
  }
  if (controllerClass == Nil) {
    NSLog(@"AIJIN_PLAYBOX_DEVELOPER boot_failed reason=controller_missing");
    return NO;
  }

  UIViewController *controller = [[controllerClass alloc] init];
  UINavigationController *navigation =
      [[UINavigationController alloc] initWithRootViewController:controller];
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  self.window.rootViewController = navigation;
  [self.window makeKeyAndVisible];
  NSLog(@"AIJIN_PLAYBOX_DEVELOPER ready controller=%@",
        NSStringFromClass(controllerClass));
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC),
                 dispatch_get_main_queue(), ^{
    [controller loadViewIfNeeded];
    UITableView *tableView = AijinFindTableView(controller.view);
    if (tableView == nil) {
      NSLog(@"AIJIN_PLAYBOX_DEVELOPER table_missing");
      return;
    }
    NSInteger sectionCount = [tableView.dataSource
        numberOfSectionsInTableView:tableView];
    NSLog(@"AIJIN_PLAYBOX_DEVELOPER table sections=%ld",
          (long)sectionCount);
    for (NSInteger section = 0; section < sectionCount; section++) {
      NSInteger rowCount = [tableView.dataSource tableView:tableView
                                     numberOfRowsInSection:section];
      for (NSInteger row = 0; row < rowCount; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row
                                                    inSection:section];
        UITableViewCell *cell = [tableView.dataSource tableView:tableView
                                         cellForRowAtIndexPath:indexPath];
        NSMutableArray<NSString *> *texts = NSMutableArray.array;
        AijinCollectViewText(cell, texts);
        NSLog(@"AIJIN_PLAYBOX_DEVELOPER row section=%ld row=%ld text=%@",
              (long)section, (long)row,
              [texts componentsJoinedByString:@" | "]);
      }
    }
    if ([NSProcessInfo.processInfo.arguments
            containsObject:@"--aijin-playbox-open-local-picker"]) {
      NSIndexPath *localAppRow = [NSIndexPath indexPathForRow:2 inSection:0];
      [tableView.delegate tableView:tableView
           didSelectRowAtIndexPath:localAppRow];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC),
                     dispatch_get_main_queue(), ^{
        UIViewController *presented = navigation.presentedViewController;
        if (presented == nil) {
          presented = controller.presentedViewController;
        }
        NSLog(@"AIJIN_PLAYBOX_DEVELOPER local_picker presented=%@ delegate=%@",
              NSStringFromClass(presented.class),
              NSStringFromClass(((UIDocumentPickerViewController *)presented)
                                    .delegate.class));
      });
    }
  });
  return YES;
}
@end

static void AijinRegisterFlutterPlugin(id engine, NSString *framework,
                                        NSString *className,
                                        NSString *pluginKey) {
  if (AijinLoadFramework(framework) == NULL) {
    return;
  }
  Class pluginClass = NSClassFromString(className);
  if (pluginClass == Nil) {
    pluginClass = NSClassFromString(
        [NSString stringWithFormat:@"%@.%@", framework, className]);
  }
  SEL registerSelector = NSSelectorFromString(@"registerWithRegistrar:");
  SEL registrarSelector = NSSelectorFromString(@"registrarForPlugin:");
  if (pluginClass == Nil || ![pluginClass respondsToSelector:registerSelector] ||
      ![engine respondsToSelector:registrarSelector]) {
    NSLog(@"AIJIN_FLUTTER_RUNTIME plugin_missing framework=%@ class=%@",
          framework, className);
    return;
  }
  id registrar = ((id (*)(id, SEL, id))objc_msgSend)(
      engine, registrarSelector, pluginKey);
  ((void (*)(id, SEL, id))objc_msgSend)(
      pluginClass, registerSelector, registrar);
  NSLog(@"AIJIN_FLUTTER_RUNTIME plugin_registered key=%@ class=%@",
        pluginKey, NSStringFromClass(pluginClass));
}

@interface NSProcessInfo (AijinPrivate)
- (void)setArguments:(NSArray<NSString *> *)arguments;
@end

static void AijinScheduleGuestScreenshot(NSTimeInterval delay,
                                          NSString *fileName);

static uint64_t AijinAArch64TestBitBranchTarget(uint32_t instruction,
                                                 uint64_t pc) {
  // TBZ and TBNZ both use a signed 14-bit, four-byte-aligned immediate.
  if ((instruction & 0x7E000000) != 0x36000000) {
    return 0;
  }
  int64_t immediate = (instruction >> 5) & 0x3FFF;
  if ((immediate & 0x2000) != 0) {
    immediate |= ~0x3FFFLL;
  }
  return pc + (uint64_t)(immediate * 4);
}

static uint64_t AijinAArch64ADRP(uint32_t instruction, uint64_t pc) {
  if ((instruction & 0x9F000000) != 0x90000000) {
    return 0;
  }

  int32_t immediate = (instruction & 0xFFFFE0) >> 3;
  immediate |= (instruction & 0x60000000) >> 29;
  if (instruction & 0x800000) {
    immediate |= 0xFFE00000;
  }
  return (pc & ~(0xFFFULL)) + ((int64_t)immediate * 4096LL);
}

static uint64_t AijinAArch64ADRPAdd(uint32_t adrpInstruction,
                                     uint32_t addInstruction,
                                     uint64_t pc) {
  uint64_t page = AijinAArch64ADRP(adrpInstruction, pc);
  if (page == 0 || (addInstruction & 0xFF000000) != 0x91000000) {
    return 0;
  }

  uint32_t source = (addInstruction >> 5) & 0x1F;
  if ((adrpInstruction & 0x1F) != source) {
    return 0;
  }

  uint32_t immediate = (addInstruction & 0x3FFC00) >> 10;
  uint8_t shift = (addInstruction & 0xC00000) >> 22;
  if (shift == 1) {
    immediate <<= 12;
  } else if (shift != 0) {
    return 0;
  }
  return page + immediate;
}

static uint64_t AijinAArch64ADRPLoad(uint32_t adrpInstruction,
                                      uint32_t loadInstruction,
                                      uint64_t pc) {
  uint64_t page = AijinAArch64ADRP(adrpInstruction, pc);
  if (page == 0 ||
      (adrpInstruction & 0x1F) != ((loadInstruction >> 5) & 0x1F) ||
      (loadInstruction & 0xFFC00000) != 0xF9400000) {
    return 0;
  }
  return page + (((loadInstruction >> 10) & 0xFFF) << 3);
}

static BOOL AijinAddressRangeInfo(const void *address, size_t length,
                                   vm_prot_t *protectionOut) {
  if (address == NULL || length == 0) {
    return NO;
  }
  uintptr_t start = (uintptr_t)address;
  if (start < 0x4000 || UINTPTR_MAX - start < length - 1) {
    return NO;
  }

  vm_address_t region = (vm_address_t)start;
  vm_size_t regionLength = 0;
  struct vm_region_submap_short_info_64 info = {0};
  mach_msg_type_number_t infoCount = VM_REGION_SUBMAP_SHORT_INFO_COUNT_64;
  natural_t depth = 99999;
  kern_return_t result = vm_region_recurse_64(
      mach_task_self(), &region, &regionLength, &depth,
      (vm_region_recurse_info_t)&info, &infoCount);
  if (result != KERN_SUCCESS || (info.protection & VM_PROT_READ) == 0) {
    return NO;
  }

  uintptr_t end = start + length;
  uintptr_t regionEnd = (uintptr_t)region + (uintptr_t)regionLength;
  if (start < (uintptr_t)region || end > regionEnd) {
    return NO;
  }
  if (protectionOut != NULL) {
    *protectionOut = info.protection;
  }
  return YES;
}

static BOOL AijinReadPointer(const void *address, void **valueOut) {
  if (valueOut == NULL ||
      !AijinAddressRangeInfo(address, sizeof(void *), NULL)) {
    return NO;
  }
  memcpy(valueOut, address, sizeof(void *));
  return YES;
}

static void AijinKeepGuestIdentityObjectsAlive(
    NSBundle *oldNSBundle, CFBundleRef oldCFBundle, NSBundle *guestBundle,
    CFBundleRef guestCFBundle) {
  if (AijinGuestIdentityKeepAliveObjects == nil) {
    AijinGuestIdentityKeepAliveObjects = [NSMutableArray array];
  }
  if (oldNSBundle != nil) {
    [AijinGuestIdentityKeepAliveObjects addObject:oldNSBundle];
  }
  if (oldCFBundle != NULL) {
    [AijinGuestIdentityKeepAliveObjects addObject:(__bridge id)oldCFBundle];
  }
  if (guestBundle != nil) {
    [AijinGuestIdentityKeepAliveObjects addObject:guestBundle];
  }
  if (guestCFBundle != NULL) {
    [AijinGuestIdentityKeepAliveObjects addObject:(__bridge id)guestCFBundle];
  }
}

static BOOL AijinWritePointer(void *address, void *expectedValue,
                               void *replacementValue, const char *name,
                               vm_prot_t *finalProtectionState,
                               BOOL *mappingChangedOut) {
  if (mappingChangedOut != NULL) {
    *mappingChangedOut = NO;
  }
  vm_prot_t observedProtection = VM_PROT_NONE;
  void *currentValue = NULL;
  if (!AijinAddressRangeInfo(address, sizeof(void *),
                              &observedProtection) ||
      !AijinReadPointer(address, &currentValue)) {
    NSLog(@"AIJIN_IOS27_IDENTITY write_failed name=%s reason=unreadable "
           "address=%p",
          name, address);
    return NO;
  }
  if (currentValue != expectedValue) {
    return NO;
  }
  vm_prot_t finalProtection = observedProtection;
  if (finalProtectionState != NULL) {
    if (*finalProtectionState == VM_PROT_NONE) {
      *finalProtectionState = observedProtection;
    } else {
      finalProtection = *finalProtectionState;
    }
  }

  vm_address_t pageAddress = trunc_page((vm_address_t)address);
  vm_address_t endAddress = round_page((vm_address_t)address + sizeof(void *));
  vm_size_t protectedLength = endAddress - pageAddress;
  BOOL changedProtection = (observedProtection & VM_PROT_WRITE) == 0;
  if (changedProtection) {
    vm_prot_t writableProtection =
        observedProtection | VM_PROT_WRITE;
    kern_return_t protectResult = vm_protect(
        mach_task_self(), pageAddress, protectedLength, FALSE,
        writableProtection);
    if (protectResult != KERN_SUCCESS) {
      protectResult = vm_protect(
          mach_task_self(), pageAddress, protectedLength, FALSE,
          writableProtection | VM_PROT_COPY);
      if (protectResult == KERN_SUCCESS && mappingChangedOut != NULL) {
        // VM_PROT_COPY can replace the underlying mapping and alter its
        // maximum protection. Restoring only the current protection later is
        // not enough to make an in-process host fallback provably safe.
        *mappingChangedOut = YES;
      }
    }
    if (protectResult != KERN_SUCCESS) {
      NSLog(@"AIJIN_IOS27_IDENTITY write_failed name=%s reason=vm_protect "
             "kr=%d address=%p protection=%x",
            name, protectResult, address, observedProtection);
      return NO;
    }
  }

  uintptr_t expectedBits = (uintptr_t)expectedValue;
  BOOL wroteValue = __atomic_compare_exchange_n(
      (uintptr_t *)address, &expectedBits, (uintptr_t)replacementValue, false,
      __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
  if (!wroteValue) {
    NSLog(@"AIJIN_IOS27_IDENTITY write_failed name=%s reason=value_changed "
           "address=%p observed=%p",
          name, address, (void *)expectedBits);
  }
  void *writtenValue = NULL;
  wroteValue = wroteValue && AijinReadPointer(address, &writtenValue) &&
      writtenValue == replacementValue;

  if (changedProtection || observedProtection != finalProtection) {
    kern_return_t restoreResult = vm_protect(
        mach_task_self(), pageAddress, protectedLength, FALSE,
        finalProtection);
    if (restoreResult != KERN_SUCCESS) {
      NSLog(@"AIJIN_IOS27_IDENTITY protection_restore_failed name=%s kr=%d "
             "address=%p",
            name, restoreResult, address);
      wroteValue = NO;
    }
  }
  return wroteValue;
}

static BOOL AijinPointerStorageMatchesState(void *address,
                                              void *expectedValue,
                                              vm_prot_t expectedProtection) {
  if (expectedProtection == VM_PROT_NONE) {
    return NO;
  }
  void *value = NULL;
  vm_prot_t protection = VM_PROT_NONE;
  return AijinAddressRangeInfo(address, sizeof(void *), &protection) &&
      AijinReadPointer(address, &value) && value == expectedValue &&
      protection == expectedProtection;
}

static BOOL AijinPointerCandidateMatchesImage(
    void *candidate, void *expectedValue, const void *implementation) {
  vm_prot_t protection = VM_PROT_NONE;
  void *value = NULL;
  if (((uintptr_t)candidate & (sizeof(void *) - 1)) != 0 ||
      !AijinAddressRangeInfo(candidate, sizeof(void *), &protection) ||
      (protection & VM_PROT_EXECUTE) != 0 ||
      !AijinReadPointer(candidate, &value) || value != expectedValue) {
    return NO;
  }

  Dl_info implementationInfo = {0};
  Dl_info candidateInfo = {0};
  if (dladdr(implementation, &implementationInfo) == 0 ||
      dladdr(candidate, &candidateInfo) == 0 ||
      implementationInfo.dli_fbase != candidateInfo.dli_fbase) {
    return NO;
  }
  return YES;
}

static void AijinAddUniqueStorageCandidate(void *candidate,
                                             void **candidates,
                                             size_t *candidateCount,
                                             size_t capacity) {
  if (candidate == NULL || candidates == NULL || candidateCount == NULL) {
    return;
  }
  for (size_t index = 0; index < *candidateCount; index++) {
    if (candidates[index] == candidate) {
      return;
    }
  }
  if (*candidateCount < capacity) {
    candidates[(*candidateCount)++] = candidate;
  }
}

static void **AijinFindIOS27MainNSBundleStorage(NSBundle *currentBundle) {
#if defined(__arm64__)
  Method method = class_getClassMethod(NSBundle.class, @selector(mainBundle));
  if (method == NULL || currentBundle == nil) {
    return NULL;
  }
  uint32_t *implementation = (uint32_t *)method_getImplementation(method);
  void *candidates[8] = {0};
  size_t candidateCount = 0;
  const int scanInstructionCount = 28;

  for (int index = 0; index < 20; index++) {
    if (!AijinAddressRangeInfo(&implementation[index], sizeof(uint32_t),
                                NULL)) {
      break;
    }
    for (int addDistance = 1; addDistance <= 4; addDistance++) {
      int addIndex = index + addDistance;
      if (addIndex >= scanInstructionCount ||
          !AijinAddressRangeInfo(&implementation[addIndex],
                                  sizeof(uint32_t), NULL)) {
        break;
      }
      uint32_t addInstruction = implementation[addIndex];
      uint32_t adrpRegister = implementation[index] & 0x1F;
      uint32_t addSourceRegister = (addInstruction >> 5) & 0x1F;
      uint32_t addDestinationRegister = addInstruction & 0x1F;
      if (adrpRegister != addSourceRegister ||
          addSourceRegister != addDestinationRegister) {
        continue;
      }
      uint64_t addAddress = AijinAArch64ADRPAdd(
          implementation[index], addInstruction,
          (uint64_t)&implementation[index]);
      if (addAddress == 0) {
        continue;
      }
      uint32_t addressRegister = addDestinationRegister;
      // The address is carried across a call to objc_msgSend in the iOS 27
      // implementation. Only callee-saved registers can hold that base safely.
      if (addressRegister < 19 || addressRegister > 28) {
        continue;
      }

      for (int loadDistance = addDistance + 1;
           loadDistance <= addDistance + 6;
           loadDistance++) {
        int loadIndex = index + loadDistance;
        if (loadIndex >= scanInstructionCount ||
            !AijinAddressRangeInfo(&implementation[loadIndex],
                                    sizeof(uint32_t), NULL)) {
          break;
        }
        uint32_t loadInstruction = implementation[loadIndex];
        if ((loadInstruction & 0xFFE00C00) != 0xF8400000 ||
            ((loadInstruction >> 5) & 0x1F) != addressRegister) {
          continue;
        }
        BOOL baseRegisterClobbered = NO;
        for (int intermediateIndex = addIndex + 1;
             intermediateIndex < loadIndex;
             intermediateIndex++) {
          uint32_t intermediate = implementation[intermediateIndex];
          BOOL isBranch = (intermediate & 0x7C000000) == 0x14000000;
          if (!isBranch && (intermediate & 0x1F) == addressRegister) {
            baseRegisterClobbered = YES;
            break;
          }
        }
        if (baseRegisterClobbered) {
          continue;
        }
        int64_t immediate = (loadInstruction >> 12) & 0x1FF;
        if ((immediate & 0x100) != 0) {
          immediate |= ~0x1FFLL;
        }
        void *candidate = (void *)(uintptr_t)((int64_t)addAddress + immediate);
        if (AijinPointerCandidateMatchesImage(
                candidate, (__bridge void *)currentBundle, implementation)) {
          AijinAddUniqueStorageCandidate(
              candidate, candidates, &candidateCount,
              sizeof(candidates) / sizeof(candidates[0]));
        }
      }
    }
  }

  NSLog(@"AIJIN_IOS27_IDENTITY nsbundle_candidates=%zu", candidateCount);
  return candidateCount == 1 ? (void **)candidates[0] : NULL;
#else
  return NULL;
#endif
}

static void **AijinFindLegacyMainNSBundleStorage(NSBundle *currentBundle) {
#if defined(__arm64__)
  Method method = class_getClassMethod(NSBundle.class, @selector(mainBundle));
  if (method == NULL || currentBundle == nil) {
    return NULL;
  }
  uint32_t *implementation = (uint32_t *)method_getImplementation(method);
  for (int index = 0; index < 20; index++) {
    if (!AijinAddressRangeInfo(&implementation[index],
                                sizeof(uint32_t) * 5, NULL)) {
      break;
    }
    uint64_t globalsAddress = AijinAArch64ADRPAdd(
        implementation[index], implementation[index + 1],
        (uint64_t)&implementation[index]);
    if (globalsAddress == 0) {
      continue;
    }
    if ((implementation[index + 4] & 0xFF000000) == 0xF8000000) {
      globalsAddress -= 4;
    }
    void *globals = (void *)(uintptr_t)globalsAddress;
    if (!AijinAddressRangeInfo(globals, sizeof(void *) * 20, NULL)) {
      continue;
    }
    for (int globalIndex = 0; globalIndex < 20; globalIndex++) {
      void *slot = (uint8_t *)globals + sizeof(void *) * globalIndex;
      void *value = NULL;
      if (AijinReadPointer(slot, &value) &&
          value == (__bridge void *)currentBundle) {
        return (void **)slot;
      }
    }
  }
#endif
  return NULL;
}

static void **AijinFindIOS27MainCFBundleStorage(
    CFBundleRef currentMainBundle) {
#if defined(__arm64__)
  uint32_t *implementation = (uint32_t *)CFBundleGetMainBundle;
  void *candidates[8] = {0};
  size_t candidateCount = 0;
  const int scanInstructionCount = 160;

  for (int index = 0; index < scanInstructionCount; index++) {
    if (!AijinAddressRangeInfo(&implementation[index], sizeof(uint32_t),
                                NULL)) {
      break;
    }

    if (index > 0) {
      uint64_t branchTarget = AijinAArch64TestBitBranchTarget(
          implementation[index], (uint64_t)&implementation[index]);
      uint32_t branchInstruction = 0;
      if (branchTarget != 0 &&
          AijinAddressRangeInfo((void *)branchTarget, sizeof(uint32_t),
                                 NULL)) {
        memcpy(&branchInstruction, (void *)branchTarget, sizeof(uint32_t));
        uint64_t address = AijinAArch64ADRPLoad(
            implementation[index - 1], branchInstruction,
            (uint64_t)&implementation[index - 1]);
        void *candidate = (void *)(uintptr_t)address;
        if (AijinPointerCandidateMatchesImage(
                candidate, (void *)currentMainBundle, implementation)) {
          AijinAddUniqueStorageCandidate(
              candidate, candidates, &candidateCount,
              sizeof(candidates) / sizeof(candidates[0]));
        }
      }
    }

    for (int distance = 1; distance <= 4; distance++) {
      if (index + distance >= scanInstructionCount ||
          !AijinAddressRangeInfo(&implementation[index + distance],
                                  sizeof(uint32_t), NULL)) {
        break;
      }
      uint64_t loadAddress = AijinAArch64ADRPLoad(
          implementation[index], implementation[index + distance],
          (uint64_t)&implementation[index]);
      void *loadCandidate = (void *)(uintptr_t)loadAddress;
      if (AijinPointerCandidateMatchesImage(
              loadCandidate, (void *)currentMainBundle, implementation)) {
        AijinAddUniqueStorageCandidate(
            loadCandidate, candidates, &candidateCount,
            sizeof(candidates) / sizeof(candidates[0]));
      }
      uint64_t addAddress = AijinAArch64ADRPAdd(
          implementation[index], implementation[index + distance],
          (uint64_t)&implementation[index]);
      void *addCandidate = (void *)(uintptr_t)addAddress;
      if (AijinPointerCandidateMatchesImage(
              addCandidate, (void *)currentMainBundle, implementation)) {
        AijinAddUniqueStorageCandidate(
            addCandidate, candidates, &candidateCount,
            sizeof(candidates) / sizeof(candidates[0]));
      }
    }
  }

  NSLog(@"AIJIN_IOS27_IDENTITY cfbundle_candidates=%zu", candidateCount);
  return candidateCount == 1 ? (void **)candidates[0] : NULL;
#else
  return NULL;
#endif
}

static void **AijinFindLegacyMainCFBundleStorage(
    CFBundleRef currentMainBundle) {
#if defined(__arm64__)
  uint32_t *instruction = (uint32_t *)CFBundleGetMainBundle;
  for (int index = 0; index < 100; index++, instruction++) {
    if (!AijinAddressRangeInfo(instruction, sizeof(uint32_t), NULL)) {
      break;
    }
    uint64_t branchTarget = AijinAArch64TestBitBranchTarget(
        *instruction, (uint64_t)instruction);
    if (branchTarget == 0 || instruction == (uint32_t *)CFBundleGetMainBundle) {
      continue;
    }
    uint32_t branchInstruction = 0;
    if (!AijinAddressRangeInfo((void *)branchTarget, sizeof(uint32_t), NULL)) {
      continue;
    }
    memcpy(&branchInstruction, (void *)branchTarget, sizeof(uint32_t));
    uint64_t address = AijinAArch64ADRPLoad(
        *(instruction - 1), branchInstruction,
        (uint64_t)(instruction - 1));
    void *candidate = (void *)(uintptr_t)address;
    void *value = NULL;
    if (AijinReadPointer(candidate, &value) &&
        value == (void *)currentMainBundle) {
      return (void **)candidate;
    }
  }
#endif
  return NULL;
}

typedef NS_ENUM(NSInteger, AijinGuestIdentityInstallResult) {
  AijinGuestIdentityInstallResultUnsafe = -1,
  AijinGuestIdentityInstallResultFailedSafely = 0,
  AijinGuestIdentityInstallResultSucceeded = 1,
};

static AijinGuestIdentityInstallResult
AijinInstallGuestProcessIdentity(NSString *bundlePath,
                                  NSString *executablePath) {
  NSBundle *oldNSBundle = NSBundle.mainBundle;
  CFBundleRef oldCFBundle = CFBundleGetMainBundle();
  NSString *oldArgumentZero = NSProcessInfo.processInfo.arguments.firstObject;
  NSString *oldProcessName = NSProcessInfo.processInfo.processName;
  NSBundle *guestBundle = [[NSBundle alloc] initWithPath:bundlePath];
  if (oldNSBundle == nil || oldCFBundle == NULL || guestBundle == nil ||
      guestBundle.bundleURL == nil) {
    return AijinGuestIdentityInstallResultFailedSafely;
  }
  CFBundleRef guestCFBundle = CFBundleCreate(
      kCFAllocatorDefault, (__bridge CFURLRef)guestBundle.bundleURL);
  if (guestCFBundle == NULL) {
    NSLog(@"AIJIN_IOS27_IDENTITY guest_cfbundle_create_failed path=%@",
          bundlePath);
    return AijinGuestIdentityInstallResultFailedSafely;
  }

  NSLog(@"AIJIN_IOS27_IDENTITY begin system=%@ old=%@ new=%@",
        UIDevice.currentDevice.systemVersion, oldNSBundle.executablePath,
        guestBundle.executablePath);

  void **nsBundleStorage = NULL;
  void **cfBundleStorage = NULL;
  if (@available(iOS 27.0, *)) {
    nsBundleStorage = AijinFindIOS27MainNSBundleStorage(oldNSBundle);
    cfBundleStorage = AijinFindIOS27MainCFBundleStorage(oldCFBundle);
  } else {
    nsBundleStorage = AijinFindLegacyMainNSBundleStorage(oldNSBundle);
    cfBundleStorage = AijinFindLegacyMainCFBundleStorage(oldCFBundle);
  }
  if (nsBundleStorage == NULL || cfBundleStorage == NULL) {
    NSLog(@"AIJIN_IOS27_IDENTITY storage_lookup_failed ns=%p cf=%p",
          nsBundleStorage, cfBundleStorage);
    CFRelease(guestCFBundle);
    return AijinGuestIdentityInstallResultFailedSafely;
  }

  vm_prot_t nsBundleFinalProtection = VM_PROT_NONE;
  vm_prot_t cfBundleFinalProtection = VM_PROT_NONE;
  BOOL nsForwardMappingChanged = NO;
  BOOL nsBundleReplaced = AijinWritePointer(
      nsBundleStorage, (__bridge void *)oldNSBundle,
      (__bridge void *)guestBundle, "NSBundle.mainBundle",
      &nsBundleFinalProtection, &nsForwardMappingChanged);
  void *nsBundleSlotValue = NULL;
  BOOL nsBundleSlotReadable =
      AijinReadPointer(nsBundleStorage, &nsBundleSlotValue);
  nsBundleReplaced = nsBundleReplaced && nsBundleSlotReadable &&
      nsBundleSlotValue == (__bridge void *)guestBundle &&
      NSBundle.mainBundle == guestBundle;
  if (!nsBundleReplaced) {
    BOOL rollbackWriteSucceeded = YES;
    BOOL rollbackMappingChanged = NO;
    if (nsBundleSlotReadable &&
        nsBundleSlotValue == (__bridge void *)guestBundle) {
      rollbackWriteSucceeded = AijinWritePointer(
          nsBundleStorage, (__bridge void *)guestBundle,
          (__bridge void *)oldNSBundle, "NSBundle.mainBundle.rollback",
          &nsBundleFinalProtection, &rollbackMappingChanged);
    } else if (!nsBundleSlotReadable ||
               nsBundleSlotValue != (__bridge void *)oldNSBundle) {
      rollbackWriteSucceeded = NO;
    }
    nsBundleSlotReadable = AijinReadPointer(
        nsBundleStorage, &nsBundleSlotValue);
    BOOL nsBundleRolledBack = rollbackWriteSucceeded &&
        !nsForwardMappingChanged && !rollbackMappingChanged &&
        AijinPointerStorageMatchesState(
            nsBundleStorage, (__bridge void *)oldNSBundle,
            nsBundleFinalProtection) && NSBundle.mainBundle == oldNSBundle;
    NSLog(@"AIJIN_IOS27_IDENTITY nsbundle_replace_failed rollback=%d "
           "write=%d forward_mapping=%d rollback_mapping=%d accessor_old=%d "
           "slot=%p protection=%x",
          nsBundleRolledBack, rollbackWriteSucceeded,
          nsForwardMappingChanged, rollbackMappingChanged,
          NSBundle.mainBundle == oldNSBundle, nsBundleSlotValue,
          nsBundleFinalProtection);
    if (!nsBundleRolledBack) {
      // A failed vm_protect restoration is unsafe even when the slot happens
      // to contain the old pointer. Keep both generations alive until the
      // caller terminates the contaminated process.
      AijinKeepGuestIdentityObjectsAlive(
          oldNSBundle, oldCFBundle, guestBundle, guestCFBundle);
    }
    CFRelease(guestCFBundle);
    return nsBundleRolledBack
        ? AijinGuestIdentityInstallResultFailedSafely
        : AijinGuestIdentityInstallResultUnsafe;
  }

  BOOL cfForwardMappingChanged = NO;
  BOOL cfBundleReplaced = AijinWritePointer(
      cfBundleStorage, (void *)oldCFBundle, (void *)guestCFBundle,
      "CFBundleGetMainBundle", &cfBundleFinalProtection,
      &cfForwardMappingChanged);
  void *cfBundleSlotValue = NULL;
  BOOL cfBundleSlotReadable =
      AijinReadPointer(cfBundleStorage, &cfBundleSlotValue);
  cfBundleReplaced = cfBundleReplaced && cfBundleSlotReadable &&
      cfBundleSlotValue == (void *)guestCFBundle &&
      CFBundleGetMainBundle() == guestCFBundle;
  if (!cfBundleReplaced) {
    BOOL cfRollbackWriteSucceeded = YES;
    BOOL cfRollbackMappingChanged = NO;
    if (cfBundleSlotReadable && cfBundleSlotValue == (void *)guestCFBundle) {
      cfRollbackWriteSucceeded = AijinWritePointer(
          cfBundleStorage, (void *)guestCFBundle, (void *)oldCFBundle,
          "CFBundleGetMainBundle.rollback", &cfBundleFinalProtection,
          &cfRollbackMappingChanged);
    } else if (!cfBundleSlotReadable ||
               cfBundleSlotValue != (void *)oldCFBundle) {
      cfRollbackWriteSucceeded = NO;
    }
    nsBundleSlotReadable = AijinReadPointer(
        nsBundleStorage, &nsBundleSlotValue);
    BOOL nsRollbackWriteSucceeded = YES;
    BOOL nsRollbackMappingChanged = NO;
    if (nsBundleSlotReadable &&
        nsBundleSlotValue == (__bridge void *)guestBundle) {
      nsRollbackWriteSucceeded = AijinWritePointer(
          nsBundleStorage, (__bridge void *)guestBundle,
          (__bridge void *)oldNSBundle, "NSBundle.mainBundle.rollback",
          &nsBundleFinalProtection, &nsRollbackMappingChanged);
    } else if (!nsBundleSlotReadable ||
               nsBundleSlotValue != (__bridge void *)oldNSBundle) {
      nsRollbackWriteSucceeded = NO;
    }
    cfBundleSlotReadable = AijinReadPointer(
        cfBundleStorage, &cfBundleSlotValue);
    nsBundleSlotReadable = AijinReadPointer(
        nsBundleStorage, &nsBundleSlotValue);
    BOOL cfBundleRolledBack = cfRollbackWriteSucceeded &&
        !cfForwardMappingChanged && !cfRollbackMappingChanged &&
        AijinPointerStorageMatchesState(
            cfBundleStorage, (void *)oldCFBundle,
            cfBundleFinalProtection) &&
        CFBundleGetMainBundle() == oldCFBundle;
    BOOL nsBundleRolledBack = nsRollbackWriteSucceeded &&
        !nsForwardMappingChanged && !nsRollbackMappingChanged &&
        AijinPointerStorageMatchesState(
            nsBundleStorage, (__bridge void *)oldNSBundle,
            nsBundleFinalProtection) && NSBundle.mainBundle == oldNSBundle;
    BOOL rollbackSafe = cfBundleRolledBack && nsBundleRolledBack;
    if (!rollbackSafe) {
      AijinKeepGuestIdentityObjectsAlive(
          oldNSBundle, oldCFBundle, guestBundle, guestCFBundle);
    }
    NSLog(@"AIJIN_IOS27_IDENTITY cfbundle_replace_failed cf_rollback=%d "
           "ns_rollback=%d cf_write=%d ns_write=%d cf_forward_mapping=%d "
           "cf_rollback_mapping=%d ns_forward_mapping=%d "
           "ns_rollback_mapping=%d cf_accessor_old=%d ns_accessor_old=%d "
           "cf_slot=%p ns_slot=%p cf_protection=%x ns_protection=%x",
          cfBundleRolledBack, nsBundleRolledBack,
          cfRollbackWriteSucceeded, nsRollbackWriteSucceeded,
          cfForwardMappingChanged, cfRollbackMappingChanged,
          nsForwardMappingChanged, nsRollbackMappingChanged,
          CFBundleGetMainBundle() == oldCFBundle,
          NSBundle.mainBundle == oldNSBundle, cfBundleSlotValue,
          nsBundleSlotValue, cfBundleFinalProtection,
          nsBundleFinalProtection);
    CFRelease(guestCFBundle);
    return rollbackSafe
        ? AijinGuestIdentityInstallResultFailedSafely
        : AijinGuestIdentityInstallResultUnsafe;
  }

  AijinPreviousMainBundle = oldNSBundle;
  if (AijinPreviousMainCFBundle != NULL) {
    CFRelease(AijinPreviousMainCFBundle);
  }
  AijinPreviousMainCFBundle = (CFBundleRef)CFRetain(oldCFBundle);
  AijinMainNSBundleStorage = nsBundleStorage;
  AijinMainCFBundleStorage = cfBundleStorage;
  AijinMainNSBundleProtection = nsBundleFinalProtection;
  AijinMainCFBundleProtection = cfBundleFinalProtection;
  AijinMainNSBundleMappingTainted = nsForwardMappingChanged;
  AijinMainCFBundleMappingTainted = cfForwardMappingChanged;
  AijinPreviousArgumentZero = oldArgumentZero;
  AijinPreviousProcessName = oldProcessName;
  AijinGuestMainBundle = guestBundle;
  if (AijinGuestMainCFBundle != NULL) {
    CFRelease(AijinGuestMainCFBundle);
  }
  AijinGuestMainCFBundle = guestCFBundle;

  NSMutableArray<NSString *> *arguments =
      NSProcessInfo.processInfo.arguments.mutableCopy;
  SEL setArgumentsSelector = NSSelectorFromString(@"setArguments:");
  if (arguments.count > 0 &&
      [NSProcessInfo.processInfo respondsToSelector:setArgumentsSelector]) {
    arguments[0] = executablePath;
    @try {
      ((void (*)(id, SEL, id))objc_msgSend)(
          NSProcessInfo.processInfo, setArgumentsSelector, arguments);
      Class swiftProcessInfo = NSClassFromString(@"_NSSwiftProcessInfo");
      SEL argumentsSelector = @selector(arguments);
      Method swiftArguments = swiftProcessInfo == Nil
          ? NULL
          : class_getInstanceMethod(swiftProcessInfo, argumentsSelector);
      Method processArguments =
          class_getInstanceMethod(NSProcessInfo.class, argumentsSelector);
      if (swiftArguments != NULL && processArguments != NULL) {
        method_setImplementation(swiftArguments,
                                 method_getImplementation(processArguments));
      }
    } @catch (NSException *exception) {
      NSLog(@"AIJIN_IOS27_IDENTITY arguments_update_failed name=%@ reason=%@",
            exception.name, exception.reason);
    }
  }
  NSString *processName = guestBundle.infoDictionary[@"CFBundleExecutable"];
  if (processName.length > 0) {
    NSProcessInfo.processInfo.processName = processName;
    setprogname(processName.UTF8String);
  }

  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_identity nsbundle=%d cfbundle=%d "
         "ns_storage=%p cf_storage=%p path=%@ identifier=%@ executable=%@",
        nsBundleReplaced, cfBundleReplaced, nsBundleStorage, cfBundleStorage,
        NSBundle.mainBundle.bundlePath, NSBundle.mainBundle.bundleIdentifier,
        NSProcessInfo.processInfo.arguments.firstObject);
  return AijinGuestIdentityInstallResultSucceeded;
}

static BOOL AijinRestorePreviousProcessIdentity(void) {
  BOOL hasAnyTransactionState = AijinMainNSBundleStorage != NULL ||
      AijinMainCFBundleStorage != NULL || AijinPreviousMainBundle != nil ||
      AijinPreviousMainCFBundle != NULL || AijinGuestMainBundle != nil ||
      AijinGuestMainCFBundle != NULL ||
      AijinPreviousArgumentZero != nil || AijinPreviousProcessName != nil ||
      AijinMainNSBundleProtection != VM_PROT_NONE ||
      AijinMainCFBundleProtection != VM_PROT_NONE ||
      AijinMainNSBundleMappingTainted || AijinMainCFBundleMappingTainted;
  if (!hasAnyTransactionState) {
    return YES;
  }
  BOOL hasCompleteTransactionState = AijinMainNSBundleStorage != NULL &&
      AijinMainCFBundleStorage != NULL && AijinPreviousMainBundle != nil &&
      AijinPreviousMainCFBundle != NULL && AijinGuestMainBundle != nil &&
      AijinGuestMainCFBundle != NULL &&
      AijinPreviousArgumentZero != nil && AijinPreviousProcessName != nil &&
      AijinMainNSBundleProtection != VM_PROT_NONE &&
      AijinMainCFBundleProtection != VM_PROT_NONE;
  if (!hasCompleteTransactionState) {
    AijinKeepGuestIdentityObjectsAlive(
        AijinPreviousMainBundle, AijinPreviousMainCFBundle,
        AijinGuestMainBundle, AijinGuestMainCFBundle);
    NSLog(@"AIJIN_IOS27_IDENTITY host_restore_failed reason=partial_transaction "
           "ns_storage=%p cf_storage=%p old_ns=%d old_cf=%d guest_ns=%d "
           "guest_cf=%d ns_protection=%x cf_protection=%x",
          AijinMainNSBundleStorage, AijinMainCFBundleStorage,
          AijinPreviousMainBundle != nil,
          AijinPreviousMainCFBundle != NULL, AijinGuestMainBundle != nil,
          AijinGuestMainCFBundle != NULL, AijinMainNSBundleProtection,
          AijinMainCFBundleProtection);
    return NO;
  }
  if (AijinMainNSBundleMappingTainted || AijinMainCFBundleMappingTainted) {
    AijinKeepGuestIdentityObjectsAlive(
        AijinPreviousMainBundle, AijinPreviousMainCFBundle,
        AijinGuestMainBundle, AijinGuestMainCFBundle);
    NSLog(@"AIJIN_IOS27_IDENTITY host_restore_failed "
           "reason=forward_mapping_tainted ns=%d cf=%d",
          AijinMainNSBundleMappingTainted,
          AijinMainCFBundleMappingTainted);
    return NO;
  }

  void *nsBundleSlotValue = NULL;
  BOOL nsBundleSlotReadable = AijinReadPointer(
      AijinMainNSBundleStorage, &nsBundleSlotValue);
  BOOL nsBundleWriteSucceeded = YES;
  BOOL nsBundleMappingChanged = NO;
  if (nsBundleSlotReadable &&
      nsBundleSlotValue == (__bridge void *)AijinGuestMainBundle) {
    nsBundleWriteSucceeded = AijinWritePointer(
        AijinMainNSBundleStorage,
        (__bridge void *)AijinGuestMainBundle,
        (__bridge void *)AijinPreviousMainBundle,
        "NSBundle.mainBundle.host_restore", &AijinMainNSBundleProtection,
        &nsBundleMappingChanged);
  } else if (!nsBundleSlotReadable ||
             nsBundleSlotValue != (__bridge void *)AijinPreviousMainBundle) {
    nsBundleWriteSucceeded = NO;
  }

  void *cfBundleSlotValue = NULL;
  BOOL cfBundleSlotReadable = AijinReadPointer(
      AijinMainCFBundleStorage, &cfBundleSlotValue);
  BOOL cfBundleWriteSucceeded = YES;
  BOOL cfBundleMappingChanged = NO;
  if (cfBundleSlotReadable &&
      cfBundleSlotValue == (void *)AijinGuestMainCFBundle) {
    cfBundleWriteSucceeded = AijinWritePointer(
        AijinMainCFBundleStorage,
        (void *)AijinGuestMainCFBundle,
        (void *)AijinPreviousMainCFBundle,
        "CFBundleGetMainBundle.host_restore", &AijinMainCFBundleProtection,
        &cfBundleMappingChanged);
  } else if (!cfBundleSlotReadable ||
             cfBundleSlotValue != (void *)AijinPreviousMainCFBundle) {
    cfBundleWriteSucceeded = NO;
  }

  nsBundleSlotReadable = AijinReadPointer(
      AijinMainNSBundleStorage, &nsBundleSlotValue);
  cfBundleSlotReadable = AijinReadPointer(
      AijinMainCFBundleStorage, &cfBundleSlotValue);
  BOOL nsBundleRestored = nsBundleWriteSucceeded &&
      !nsBundleMappingChanged &&
      AijinPointerStorageMatchesState(
          AijinMainNSBundleStorage,
          (__bridge void *)AijinPreviousMainBundle,
          AijinMainNSBundleProtection);
  BOOL cfBundleRestored = cfBundleWriteSucceeded &&
      !cfBundleMappingChanged &&
      AijinPointerStorageMatchesState(
          AijinMainCFBundleStorage, (void *)AijinPreviousMainCFBundle,
          AijinMainCFBundleProtection);
  BOOL accessorsRestored = NSBundle.mainBundle == AijinPreviousMainBundle &&
      CFBundleGetMainBundle() == AijinPreviousMainCFBundle;
  if (!nsBundleRestored || !cfBundleRestored || !accessorsRestored) {
    AijinKeepGuestIdentityObjectsAlive(
        AijinPreviousMainBundle, AijinPreviousMainCFBundle,
        AijinGuestMainBundle, AijinGuestMainCFBundle);
    NSLog(@"AIJIN_IOS27_IDENTITY host_restore_failed ns=%d cf=%d "
           "ns_write=%d cf_write=%d ns_mapping=%d cf_mapping=%d "
           "accessors=%d ns_slot=%p cf_slot=%p",
          nsBundleRestored, cfBundleRestored, nsBundleWriteSucceeded,
          cfBundleWriteSucceeded, nsBundleMappingChanged,
          cfBundleMappingChanged, accessorsRestored, nsBundleSlotValue,
          cfBundleSlotValue);
    return NO;
  }

  BOOL argumentsRestored = AijinPreviousArgumentZero.length == 0;
  NSMutableArray<NSString *> *arguments =
      NSProcessInfo.processInfo.arguments.mutableCopy;
  SEL setArgumentsSelector = NSSelectorFromString(@"setArguments:");
  if (arguments.count > 0 && AijinPreviousArgumentZero.length > 0 &&
      [NSProcessInfo.processInfo respondsToSelector:setArgumentsSelector]) {
    arguments[0] = AijinPreviousArgumentZero;
    @try {
      ((void (*)(id, SEL, id))objc_msgSend)(
          NSProcessInfo.processInfo, setArgumentsSelector, arguments);
      argumentsRestored = [NSProcessInfo.processInfo.arguments.firstObject
          isEqualToString:AijinPreviousArgumentZero];
    } @catch (NSException *exception) {
      NSLog(@"AIJIN_IOS27_IDENTITY host_arguments_restore_failed name=%@ "
             "reason=%@",
            exception.name, exception.reason);
      argumentsRestored = NO;
    }
  }
  BOOL processNameRestored = AijinPreviousProcessName.length == 0;
  if (AijinPreviousProcessName.length > 0) {
    NSProcessInfo.processInfo.processName = AijinPreviousProcessName;
    setprogname(AijinPreviousProcessName.UTF8String);
    processNameRestored = [NSProcessInfo.processInfo.processName
        isEqualToString:AijinPreviousProcessName];
  }
  if (!argumentsRestored || !processNameRestored) {
    AijinKeepGuestIdentityObjectsAlive(
        AijinPreviousMainBundle, AijinPreviousMainCFBundle,
        AijinGuestMainBundle, AijinGuestMainCFBundle);
    NSLog(@"AIJIN_IOS27_IDENTITY host_restore_failed reason=metadata "
           "arguments=%d process_name=%d",
          argumentsRestored, processNameRestored);
    return NO;
  }

  CFBundleRef previousCFBundle = AijinPreviousMainCFBundle;
  CFBundleRef guestCFBundle = AijinGuestMainCFBundle;
  AijinGuestMainBundle = nil;
  AijinPreviousMainBundle = nil;
  AijinGuestMainCFBundle = NULL;
  AijinPreviousMainCFBundle = NULL;
  if (guestCFBundle != NULL) {
    CFRelease(guestCFBundle);
  }
  if (previousCFBundle != NULL) {
    CFRelease(previousCFBundle);
  }
  AijinMainNSBundleStorage = NULL;
  AijinMainCFBundleStorage = NULL;
  AijinMainNSBundleProtection = VM_PROT_NONE;
  AijinMainCFBundleProtection = VM_PROT_NONE;
  AijinMainNSBundleMappingTainted = NO;
  AijinMainCFBundleMappingTainted = NO;
  AijinPreviousArgumentZero = nil;
  AijinPreviousProcessName = nil;
  NSLog(@"AIJIN_IOS27_IDENTITY host_restored path=%@ identifier=%@",
        NSBundle.mainBundle.bundlePath, NSBundle.mainBundle.bundleIdentifier);
  return YES;
}

static BOOL AijinRestoreHostApplicationSurface(void) {
  AijinGuestLaunchGeneration += 1;
  AijinResetInProcessGuestLifecycle();
  AijinCancelGuestWindowVisibilityDeferral();
  if (!AijinHostApplicationSurfaceCaptured) {
    AijinInProcessGuestRootController = nil;
    AijinInProcessGuestWindow = nil;
    AijinInProcessGuestDelegate = nil;
    return YES;
  }

  UIApplication *application = UIApplication.sharedApplication;
  SEL setDelegateSelector = NSSelectorFromString(@"setDelegate:");
  BOOL delegateRestored = application.delegate == AijinHostApplicationDelegate;
  if (AijinHostApplicationDelegate != nil &&
      application.delegate != AijinHostApplicationDelegate) {
    if ([application respondsToSelector:setDelegateSelector]) {
      ((void (*)(id, SEL, id))objc_msgSend)(
          application, setDelegateSelector, AijinHostApplicationDelegate);
      delegateRestored = application.delegate == AijinHostApplicationDelegate;
    } else {
      delegateRestored = NO;
    }
  }
  if (AijinInProcessGuestWindow != nil &&
      AijinInProcessGuestWindow != AijinHostApplicationWindow) {
    AijinInProcessGuestWindow.hidden = YES;
  }
  BOOL rootRestored = AijinHostApplicationWindow == nil;
  BOOL visibilityRestored = AijinHostApplicationWindow == nil;
  BOOL keyStateRestored = !AijinHostWindowWasKey;
  if (AijinHostApplicationWindow != nil) {
    if (AijinOriginalSetRootViewController != NULL) {
      ((void (*)(id, SEL, id))AijinOriginalSetRootViewController)(
          AijinHostApplicationWindow, @selector(setRootViewController:),
          AijinHostRootViewController);
    } else {
      AijinHostApplicationWindow.rootViewController =
          AijinHostRootViewController;
    }
    AijinHostApplicationWindow.hidden = AijinHostWindowWasHidden;
    if (AijinHostWindowWasKey && !AijinHostWindowWasHidden) {
      [AijinHostApplicationWindow makeKeyAndVisible];
    }
    rootRestored = AijinHostApplicationWindow.rootViewController ==
        AijinHostRootViewController;
    visibilityRestored = AijinHostApplicationWindow.hidden ==
        AijinHostWindowWasHidden;
    keyStateRestored = !AijinHostWindowWasKey ||
        AijinHostApplicationWindow.isKeyWindow;
  }
  BOOL restored = delegateRestored && rootRestored && visibilityRestored &&
      keyStateRestored;
  if (!restored) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME host_surface_restore_failed delegate=%d "
           "root=%d visibility=%d key=%d",
          delegateRestored, rootRestored, visibilityRestored,
          keyStateRestored);
  }
  AijinInProcessGuestRootController = nil;
  AijinInProcessGuestWindow = nil;
  AijinInProcessGuestDelegate = nil;
  AijinHostRootViewController = nil;
  AijinHostApplicationWindow = nil;
  AijinHostApplicationDelegate = nil;
  AijinHostWindowWasHidden = NO;
  AijinHostWindowWasKey = NO;
  AijinHostApplicationSurfaceCaptured = NO;
  return restored;
}

// PackageInfo must describe the verified guest, not the Aijin host.
static IMP AijinOriginalPackageInfoMethod;
static NSDictionary *AijinFlutterInstalledMetadata;

static void AijinGuestPackageInfo(id self, SEL command, id call, void (^result)(id)) {
  NSString *method = [call valueForKey:@"method"];
  if (![method isEqualToString:@"getAll"]) {
    ((void (*)(id, SEL, id, id))AijinOriginalPackageInfoMethod)(self, command, call, result);
    return;
  }
  void (^guestResult)(id) = ^(id value) {
    if (![value isKindOfClass:NSDictionary.class]) { result(value); return; }
    NSMutableDictionary *info = [value mutableCopy];
    NSDictionary *keys = @{@"packageName": @"CFBundleIdentifier",
                           @"appName": @"CFBundleDisplayName",
                           @"version": @"CFBundleShortVersionString",
                           @"buildNumber": @"CFBundleVersion"};
    for (NSString *key in keys) {
      NSString *verified = AijinFlutterInstalledMetadata[keys[key]];
      if ([verified isKindOfClass:NSString.class] && verified.length > 0) {
        info[key] = verified;
      }
    }
    NSLog(@"AIJIN_FLUTTER_RUNTIME package_info guest=%@ version=%@+%@",
          info[@"packageName"], info[@"version"], info[@"buildNumber"]);
    result(info);
  };
  ((void (*)(id, SEL, id, id))AijinOriginalPackageInfoMethod)(self, command, call, guestResult);
}

static void AijinInstallGuestPackageInfo(NSDictionary *metadata) {
  AijinFlutterInstalledMetadata = metadata;
  Class plugin = NSClassFromString(@"FPPPackageInfoPlusPlugin");
  Method method = class_getInstanceMethod(plugin, NSSelectorFromString(@"handleMethodCall:result:"));
  if (method != NULL && AijinOriginalPackageInfoMethod == NULL) {
    AijinOriginalPackageInfoMethod = method_getImplementation(method);
    method_setImplementation(method, (IMP)AijinGuestPackageInfo);
  }
}

@interface AijinFlutterGuestDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) id guestEngine;
@end

@implementation AijinFlutterGuestDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSURL *documentsURL = [NSFileManager.defaultManager
      URLsForDirectory:NSDocumentDirectory
      inDomains:NSUserDomainMask].lastObject;
  NSString *guestBundlePath = [[documentsURL URLByAppendingPathComponent:
      @"Applications/app.nqyqstm6mu.tianya.runtime/Guest.bundle"] path];
  NSBundle *guestBundle = [[NSBundle alloc] initWithPath:guestBundlePath];
  if (guestBundle == nil ||
      ![NSFileManager.defaultManager fileExistsAtPath:
          [guestBundlePath stringByAppendingPathComponent:@"flutter_assets/kernel_blob.bin"]]) {
    NSLog(@"AIJIN_FLUTTER_RUNTIME guest_boot_failed reason=artifact_missing path=%@",
          guestBundlePath);
    return NO;
  }

  Class projectClass = NSClassFromString(@"FlutterDartProject");
  Class engineClass = NSClassFromString(@"FlutterEngine");
  Class controllerClass = NSClassFromString(@"FlutterViewController");
  if (projectClass == Nil || engineClass == Nil || controllerClass == Nil) {
    NSLog(@"AIJIN_FLUTTER_RUNTIME guest_boot_failed reason=flutter_classes_missing");
    return NO;
  }

  id project = ((id (*)(id, SEL, id))objc_msgSend)(
      [projectClass alloc], NSSelectorFromString(@"initWithPrecompiledDartBundle:"),
      guestBundle);
  id engine = ((id (*)(id, SEL, id, id, BOOL))objc_msgSend)(
      [engineClass alloc],
      NSSelectorFromString(@"initWithName:project:allowHeadlessExecution:"),
      @"aijin.pornhub", project, YES);
  BOOL started = ((BOOL (*)(id, SEL, id))objc_msgSend)(
      engine, NSSelectorFromString(@"runWithEntrypoint:"), nil);
  if (!started) {
    NSLog(@"AIJIN_FLUTTER_RUNTIME guest_boot_failed reason=engine_start");
    return NO;
  }
  self.guestEngine = engine;

  // These plugins are required by the startup/account path. They are copied
  // from the exact approved IPA and loaded only in the Flutter guest process.
  AijinRegisterFlutterPlugin(engine, @"shared_preferences_foundation",
                              @"SharedPreferencesPlugin",
                              @"SharedPreferencesPlugin");
  AijinRegisterFlutterPlugin(engine, @"device_info_plus",
                              @"FPPDeviceInfoPlusPlugin",
                              @"FPPDeviceInfoPlusPlugin");
  AijinRegisterFlutterPlugin(engine, @"package_info_plus",
                              @"FPPPackageInfoPlusPlugin",
                              @"FPPPackageInfoPlusPlugin");
  NSDictionary *verifiedMetadata = [NSDictionary dictionaryWithContentsOfFile:
      [[guestBundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Installed.plist"]];
  AijinInstallGuestPackageInfo(verifiedMetadata);
  AijinRegisterFlutterPlugin(engine, @"connectivity_plus",
                              @"ConnectivityPlusPlugin",
                              @"ConnectivityPlusPlugin");
  AijinRegisterFlutterPlugin(engine, @"flutter_secure_storage",
                              @"FlutterSecureStoragePlugin",
                              @"FlutterSecureStoragePlugin");
  AijinLoadFramework(@"JNKeychain");
  AijinRegisterFlutterPlugin(engine, @"mobile_device_identifier",
                              @"SwiftMobileDeviceIdentifierPlugin",
                              @"SwiftMobileDeviceIdentifierPlugin");
  AijinRegisterFlutterPlugin(engine, @"path_provider_foundation",
                              @"PathProviderPlugin",
                              @"PathProviderPlugin");

  UIViewController *controller = ((id (*)(id, SEL, id, id, id))objc_msgSend)(
      [controllerClass alloc], NSSelectorFromString(@"initWithEngine:nibName:bundle:"),
      engine, nil, nil);
  if ([controller respondsToSelector:NSSelectorFromString(@"setFlutterViewDidRenderCallback:")]) {
    void (^firstFrame)(void) = ^{
      NSLog(@"AIJIN_FLUTTER_RUNTIME guest_first_frame");
      AijinScheduleGuestScreenshot(1, @"flutter-guest-screen.png");
      AijinScheduleGuestScreenshot(15, @"flutter-guest-screen-15.png");
      AijinScheduleGuestScreenshot(30, @"flutter-guest-screen-30.png");
    };
    ((void (*)(id, SEL, id))objc_msgSend)(
        controller, NSSelectorFromString(@"setFlutterViewDidRenderCallback:"),
        firstFrame);
  }

  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  self.window.rootViewController = controller;
  [self.window makeKeyAndVisible];
  AijinInstallGuestFloatingControl(self.window);
  NSLog(@"AIJIN_FLUTTER_RUNTIME guest_engine_started runtime=flutter_debug_arm64_simulator bundle=app.nqyqstm6mu.tianya");
  return YES;
}
@end

static int AijinRunFlutterGuest(int argc, char *argv[]) {
  if (AijinLoadFramework(@"Flutter") == NULL) {
    return -1;
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-signals"]) {
    AijinInstallDiagnosticSignalHandler();
    AijinWriteDiagnosticStage("runtime_loaded");
  }
  NSLog(@"AIJIN_FLUTTER_RUNTIME guest_boot");
  return UIApplicationMain(argc, argv, nil,
                           NSStringFromClass(AijinFlutterGuestDelegate.class));
}

// PBPlayerKit's public NUDGuestHooksInit entry point expects this compatibility
// selector to be supplied by the PlayBox host executable. It uses the value as
// the guest's isolated NSUserDefaults domain identifier.
@interface NSUserDefaults (AijinPlayBoxCompatibility)
+ (NSUserDefaults *)mainDefaults;
+ (NSString *)runGuestAppBid;
@end

@implementation NSUserDefaults (AijinPlayBoxCompatibility)
+ (NSUserDefaults *)mainDefaults {
  return NSUserDefaults.standardUserDefaults;
}

+ (NSString *)runGuestAppBid {
  NSString *bundleIdentifier = [NSUserDefaults.standardUserDefaults
      stringForKey:@"TempMailPlayBoxGuestBundleIdentifier"];
  return bundleIdentifier.length > 0
      ? bundleIdentifier
      : @"com.amk2ns2n9j.alan2is71";
}
@end

@interface UNUserNotificationCenter (AijinPlayBoxCompatibility)
+ (UNUserNotificationCenter *)mainCenter;
@end

@implementation UNUserNotificationCenter (AijinPlayBoxCompatibility)
+ (UNUserNotificationCenter *)mainCenter {
  return UNUserNotificationCenter.currentNotificationCenter;
}
@end

static char AijinGuestCrashBuffer[2048];
static volatile sig_atomic_t AijinGuestCrashBufferLength = 0;

static void AijinGuestCrashHandler(const char *message) {
  static volatile sig_atomic_t handlingGuestCrash = 0;
  if (handlingGuestCrash != 0) {
    const sig_atomic_t bufferedLength = AijinGuestCrashBufferLength;
    if (bufferedLength > 0) {
      write(STDERR_FILENO, AijinGuestCrashBuffer, (size_t)bufferedLength);
      if (AijinDiagnosticSignalFile >= 0) {
        write(AijinDiagnosticSignalFile, AijinGuestCrashBuffer,
              (size_t)bufferedLength);
      }
    }
    _exit(190);
  }
  handlingGuestCrash = 1;

  const char *safe_message =
      message == NULL ? "unknown guest runtime failure" : message;
  char *buffer = AijinGuestCrashBuffer;
  AijinGuestCrashBufferLength = 0;
  const char prefix[] = "AIJIN_GUEST_CRASH_RAW error=";
  size_t cursor = 0;
  for (size_t index = 0;
       index < sizeof(prefix) - 1 &&
       cursor < sizeof(AijinGuestCrashBuffer) - 1;
       index += 1) {
    buffer[cursor++] = prefix[index];
    AijinGuestCrashBufferLength = (sig_atomic_t)cursor;
  }
  for (size_t index = 0;
       safe_message[index] != '\0' &&
       cursor < sizeof(AijinGuestCrashBuffer) - 2;
       index += 1) {
    buffer[cursor++] = safe_message[index];
    AijinGuestCrashBufferLength = (sig_atomic_t)cursor;
  }
  buffer[cursor++] = '\n';
  AijinGuestCrashBufferLength = (sig_atomic_t)cursor;
  write(STDERR_FILENO, buffer, cursor);
  if (AijinDiagnosticSignalFile >= 0) {
    write(AijinDiagnosticSignalFile, buffer, cursor);
  }
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_crash error=%s", safe_message);
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-signals"]) {
    _exit(190);
  }
  if (AijinAdversarysAbort != NULL) {
    AijinAdversarysAbort(-1);
  }
  handlingGuestCrash = 0;
}

static void AijinScheduleGuestScreenshot(NSTimeInterval delay,
                                          NSString *fileName) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                               (int64_t)(delay * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
    UIWindow *targetWindow =
        AijinCurrentForegroundWindow(UIApplication.sharedApplication);
    if (targetWindow == nil) {
    NSLog(@"AIJIN_RUNTIME guest_screenshot_failed reason=no_window");
      return;
    }

    UIGraphicsBeginImageContextWithOptions(targetWindow.bounds.size, NO,
                                           UIScreen.mainScreen.scale);
    BOOL rendered = [targetWindow drawViewHierarchyInRect:targetWindow.bounds
                                       afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *png = image == nil ? nil : UIImagePNGRepresentation(image);
    NSURL *documentsURL = [NSFileManager.defaultManager
        URLsForDirectory:NSDocumentDirectory
        inDomains:NSUserDomainMask].lastObject;
    NSURL *diagnosticsDirectory = [documentsURL
        URLByAppendingPathComponent:@"TempMailTest" isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:diagnosticsDirectory
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
    NSURL *screenshotURL = [diagnosticsDirectory
        URLByAppendingPathComponent:fileName];
    BOOL written = [png writeToURL:screenshotURL atomically:YES];
    NSLog(@"AIJIN_RUNTIME guest_screenshot file=%@ rendered=%d written=%d bytes=%lu root=%@",
          fileName, rendered, written, (unsigned long)png.length,
          NSStringFromClass(targetWindow.rootViewController.class));
  });
}

static NSString *AijinImageForImplementation(IMP implementation) {
  if (implementation == NULL) {
    return @"missing";
  }
  Dl_info info = {0};
  if (dladdr((const void *)implementation, &info) == 0 ||
      info.dli_fname == NULL) {
    return @"unknown";
  }
  return [NSString stringWithUTF8String:info.dli_fname].lastPathComponent;
}

static void AijinInspectGuestRegistration(NSTimeInterval delay) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                               (int64_t)(delay * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
    UIApplication *application = UIApplication.sharedApplication;
    id delegate = application.delegate;
    UIWindow *window = nil;
    if ([delegate respondsToSelector:@selector(window)]) {
      window = ((id (*)(id, SEL))objc_msgSend)(delegate, @selector(window));
    }
    if (window == nil) {
      window = application.windows.firstObject;
    }
    UIViewController *root = window.rootViewController;
    Class registrant = NSClassFromString(@"GeneratedPluginRegistrant");
    Class superPlayer = NSClassFromString(@"SuperPlayerPlugin");
    SEL registerSelector = NSSelectorFromString(@"registerWithRegistry:");
    SEL pluginSelector = NSSelectorFromString(@"registerWithRegistrar:");
    IMP registrantIMP = registrant == Nil ? NULL :
        method_getImplementation(class_getClassMethod(registrant,
                                                       registerSelector));
    IMP superPlayerIMP = superPlayer == Nil ? NULL :
        method_getImplementation(class_getClassMethod(superPlayer,
                                                       pluginSelector));
    SEL hasPluginSelector = NSSelectorFromString(@"hasPlugin:");
    BOOL supportsHasPlugin = [delegate respondsToSelector:hasPluginSelector];
    BOOL hasSuperPlayer = supportsHasPlugin &&
        ((BOOL (*)(id, SEL, id))objc_msgSend)(delegate, hasPluginSelector,
                                             @"SuperPlayerPlugin");
    BOOL hasNoScreenshot = supportsHasPlugin &&
        ((BOOL (*)(id, SEL, id))objc_msgSend)(delegate, hasPluginSelector,
                                             @"NoScreenshotPlugin");
    SEL engineSelector = NSSelectorFromString(@"engine");
    if (![root respondsToSelector:engineSelector]) {
      engineSelector = NSSelectorFromString(@"flutterEngine");
    }
    id engine = [root respondsToSelector:engineSelector]
        ? ((id (*)(id, SEL))objc_msgSend)(root, engineSelector)
        : nil;
    SEL isolateSelector = NSSelectorFromString(@"isolateId");
    id isolateID = [engine respondsToSelector:isolateSelector]
        ? ((id (*)(id, SEL))objc_msgSend)(engine, isolateSelector)
        : nil;
    SEL displayingSelector = NSSelectorFromString(@"isDisplayingFlutterUI");
    BOOL displayingFlutterUI = [root respondsToSelector:displayingSelector] &&
        ((BOOL (*)(id, SEL))objc_msgSend)(root, displayingSelector);
    SEL renderCallbackSelector =
        NSSelectorFromString(@"setFlutterViewDidRenderCallback:");
    if (!AijinDiagnosticFirstFrameHooked &&
        [root respondsToSelector:renderCallbackSelector]) {
      AijinDiagnosticFirstFrameHooked = YES;
      void (^callback)(void) = ^{
        NSLog(@"AIJIN_DIAGNOSTIC_GUEST_FIRST_FRAME");
      };
      ((void (*)(id, SEL, id))objc_msgSend)(root, renderCallbackSelector,
                                           callback);
    }
    NSLog(@"AIJIN_DIAGNOSTIC_GUEST_STATE delay=%.0f delegate=%@ root=%@ "
          "registrant=%@ registrant_image=%@ super_player=%@ "
          "super_player_image=%@ has_api=%d has_super_player=%d "
          "has_no_screenshot=%d engine=%@ isolate=%@ displaying=%d "
          "view_window=%d subviews=%lu layer=%@",
          delay, NSStringFromClass([delegate class]),
          NSStringFromClass([root class]), NSStringFromClass(registrant),
          AijinImageForImplementation(registrantIMP),
          NSStringFromClass(superPlayer),
          AijinImageForImplementation(superPlayerIMP), supportsHasPlugin,
          hasSuperPlayer, hasNoScreenshot, NSStringFromClass([engine class]),
          isolateID, displayingFlutterUI, root.view.window != nil,
          (unsigned long)root.view.subviews.count,
          NSStringFromClass([root.view.layer class]));
  });
}

static BOOL AijinAcquireGuestRuntimeLaunchClaim(void) {
  int expected = 0;
  return __atomic_compare_exchange_n(
      &AijinGuestRuntimeLaunchClaim, &expected, 1, false,
      __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
}

static void AijinReleaseGuestRuntimeLaunchClaim(void) {
  __atomic_store_n(&AijinGuestRuntimeLaunchClaim, 0, __ATOMIC_SEQ_CST);
}

static BOOL AijinHBuilderWWWNeedsRefresh(NSString *sourceWWW,
                                         NSString *destinationWWW) {
  NSFileManager *files = NSFileManager.defaultManager;
  BOOL destinationIsDirectory = NO;
  if (![files fileExistsAtPath:destinationWWW
                   isDirectory:&destinationIsDirectory] ||
      !destinationIsDirectory) {
    return YES;
  }
  for (NSString *relativePath in @[
         @"__uniappview.html", @"manifest.json", @"app-service.js",
         @"app-view.js", @"app-config.js"
       ]) {
    NSData *sourceData = [NSData dataWithContentsOfFile:
        [sourceWWW stringByAppendingPathComponent:relativePath]];
    NSData *destinationData = [NSData dataWithContentsOfFile:
        [destinationWWW stringByAppendingPathComponent:relativePath]];
    if (sourceData == nil || destinationData == nil ||
        ![sourceData isEqualToData:destinationData]) {
      return YES;
    }
  }
  return NO;
}

static BOOL AijinSynchronizeHBuilderWebResources(NSString *bundlePath) {
  NSFileManager *files = NSFileManager.defaultManager;
  NSString *sourceApps = [bundlePath
      stringByAppendingPathComponent:@"Pandora/apps"];
  BOOL sourceIsDirectory = NO;
  if (![files fileExistsAtPath:sourceApps isDirectory:&sourceIsDirectory] ||
      !sourceIsDirectory) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
           "reason=source_apps_missing path=%@",
          sourceApps);
    return NO;
  }

  NSURL *libraryURL = [files URLsForDirectory:NSLibraryDirectory
                                     inDomains:NSUserDomainMask].lastObject;
  NSString *destinationApps = [[libraryURL URLByAppendingPathComponent:
      @"Pandora/apps" isDirectory:YES] path];
  NSError *directoryError = nil;
  if (![files createDirectoryAtPath:destinationApps
         withIntermediateDirectories:YES
                          attributes:nil
                               error:&directoryError]) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
           "reason=destination_apps error=%@",
          directoryError.localizedDescription ?: @"unknown");
    return NO;
  }

  NSError *enumerationError = nil;
  NSArray<NSString *> *appIdentifiers =
      [files contentsOfDirectoryAtPath:sourceApps error:&enumerationError];
  if (appIdentifiers == nil) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
           "reason=enumerate error=%@",
          enumerationError.localizedDescription ?: @"unknown");
    return NO;
  }

  NSUInteger synchronizedApps = 0;
  for (NSString *appIdentifier in appIdentifiers) {
    NSString *sourceWWW = [[sourceApps
        stringByAppendingPathComponent:appIdentifier]
        stringByAppendingPathComponent:@"www"];
    BOOL sourceWWWIsDirectory = NO;
    if (![files fileExistsAtPath:sourceWWW
                     isDirectory:&sourceWWWIsDirectory] ||
        !sourceWWWIsDirectory ||
        ![files fileExistsAtPath:[sourceWWW
            stringByAppendingPathComponent:@"__uniappview.html"]]) {
      continue;
    }

    NSString *destinationApp =
        [destinationApps stringByAppendingPathComponent:appIdentifier];
    NSString *destinationWWW =
        [destinationApp stringByAppendingPathComponent:@"www"];
    if (!AijinHBuilderWWWNeedsRefresh(sourceWWW, destinationWWW)) {
      synchronizedApps += 1;
      NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_ready appid=%@ "
             "action=reuse",
            appIdentifier);
      continue;
    }

    NSError *appDirectoryError = nil;
    if (![files createDirectoryAtPath:destinationApp
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&appDirectoryError]) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
             "reason=destination_app appid=%@ error=%@",
            appIdentifier,
            appDirectoryError.localizedDescription ?: @"unknown");
      return NO;
    }

    NSString *stagingWWW = [destinationApp stringByAppendingPathComponent:
        [NSString stringWithFormat:@"www.aijin-staging-%@",
                                   NSUUID.UUID.UUIDString]];
    NSError *copyError = nil;
    if (![files copyItemAtPath:sourceWWW
                        toPath:stagingWWW
                         error:&copyError]) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
             "reason=copy appid=%@ error=%@",
            appIdentifier, copyError.localizedDescription ?: @"unknown");
      return NO;
    }

    NSError *activationError = nil;
    if ([files fileExistsAtPath:destinationWWW]) {
      BOOL activated = [files
          replaceItemAtURL:[NSURL fileURLWithPath:destinationWWW]
             withItemAtURL:[NSURL fileURLWithPath:stagingWWW]
            backupItemName:nil
                   options:0
          resultingItemURL:nil
                     error:&activationError];
      if (!activated) {
        [files removeItemAtPath:stagingWWW error:nil];
        NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
               "reason=replace appid=%@ error=%@",
              appIdentifier,
              activationError.localizedDescription ?: @"unknown");
        return NO;
      }
    } else if (![files moveItemAtPath:stagingWWW
                               toPath:destinationWWW
                                error:&activationError]) {
      [files removeItemAtPath:stagingWWW error:nil];
      NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
             "reason=activate appid=%@ error=%@",
            appIdentifier,
            activationError.localizedDescription ?: @"unknown");
      return NO;
    }
    synchronizedApps += 1;
    NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_ready appid=%@ "
           "action=refresh",
          appIdentifier);
  }

  if (synchronizedApps == 0) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_www_sync_failed "
           "reason=no_packaged_apps");
    return NO;
  }
  return YES;
}

static NSDictionary *AijinPrepareHBuilderSceneManifest(
    NSString *bundlePath, NSDictionary *guestInfo) {
  if (guestInfo == nil) {
    return nil;
  }
  NSString *executableName = guestInfo[@"CFBundleExecutable"];
  if (![executableName isEqualToString:@"HBuilder"] ||
      guestInfo[@"UIApplicationSceneManifest"] != nil) {
    return guestInfo;
  }

  NSMutableDictionary *updatedInfo = [guestInfo mutableCopy];
  updatedInfo[@"UIApplicationSceneManifest"] = @{
    @"UIApplicationSupportsMultipleScenes": @NO,
    @"UISceneConfigurations": @{
      @"UIWindowSceneSessionRoleApplication": @[
        @{
          @"UISceneConfigurationName": @"Aijin Guest Configuration",
          @"UISceneDelegateClassName": @"AijinGuestSceneDelegate",
        },
      ],
    },
  };

  NSString *infoPath = [bundlePath stringByAppendingPathComponent:@"Info.plist"];
  NSError *serializationError = nil;
  NSData *plistData = [NSPropertyListSerialization
      dataWithPropertyList:updatedInfo
                    format:NSPropertyListBinaryFormat_v1_0
                   options:0
                     error:&serializationError];
  if (plistData == nil) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_scene_manifest_failed "
           "reason=serialize error=%@",
          serializationError.localizedDescription ?: @"unknown");
    return nil;
  }

  NSError *writeError = nil;
  if (![plistData writeToFile:infoPath
                      options:NSDataWritingAtomic
                        error:&writeError]) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_scene_manifest_failed "
           "reason=write error=%@",
          writeError.localizedDescription ?: @"unknown");
    return nil;
  }
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_scene_manifest_installed path=%@",
        infoPath);
  return [updatedInfo copy];
}

// Host routing URLs must not be interpreted as HBuilder guest launch intents.
// A cold URL relaunch otherwise enters the guest's unrelated URL-import path.
static IMP AijinGuestOriginalDefaultFileManager;
static NSFileManager *AijinHBuilderFileManager;

static id AijinHBuilderDefaultFileManager(id self, SEL selector) {
  // A private manager accepts the delegate used by the legacy HBuilder URL
  // import path. Foundation's global default manager rejects setDelegate:.
  return AijinHBuilderFileManager;
}

static void AijinInstallHBuilderFileManager(void) {
  if (AijinGuestOriginalDefaultFileManager != NULL) { return; }
  AijinHBuilderFileManager = [[NSFileManager alloc] init];
  Method method = class_getClassMethod(NSFileManager.class, @selector(defaultManager));
  AijinGuestOriginalDefaultFileManager = method_getImplementation(method);
  method_setImplementation(method, (IMP)AijinHBuilderDefaultFileManager);
  NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_private_file_manager_installed");
}

static IMP AijinGuestOriginalWillFinish;
static IMP AijinGuestOriginalDidFinish;

static NSDictionary *AijinGuestLaunchOptions(NSDictionary *options) {
  NSURL *url = options[UIApplicationLaunchOptionsURLKey];
  if (![url isKindOfClass:NSURL.class] ||
      ![url.scheme.lowercaseString isEqualToString:@"aijin"]) {
    return options;
  }
  NSMutableDictionary *filtered = [options mutableCopy];
  [filtered removeObjectForKey:UIApplicationLaunchOptionsURLKey];
  [filtered removeObjectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
  [filtered removeObjectForKey:UIApplicationLaunchOptionsAnnotationKey];
  NSLog(@"AIJIN_PLAYBOX_RUNTIME host_launch_url_filtered");
  return filtered.count > 0 ? filtered : nil;
}

static BOOL AijinGuestWillFinish(id self, SEL command, UIApplication *app,
                                     NSDictionary *options) {
  return ((BOOL (*)(id, SEL, id, id))AijinGuestOriginalWillFinish)(
      self, command, app, AijinGuestLaunchOptions(options));
}

static BOOL AijinGuestDidFinish(id self, SEL command, UIApplication *app,
                                    NSDictionary *options) {
  return ((BOOL (*)(id, SEL, id, id))AijinGuestOriginalDidFinish)(
      self, command, app, AijinGuestLaunchOptions(options));
}

static void AijinFilterHBuilderHostLaunchIntent(void) {
  Class delegate = NSClassFromString(@"AppDelegate");
  if (delegate == Nil) { return; }
  Method will = class_getInstanceMethod(delegate, @selector(application:willFinishLaunchingWithOptions:));
  Method did = class_getInstanceMethod(delegate, @selector(application:didFinishLaunchingWithOptions:));
  if (will != NULL && AijinGuestOriginalWillFinish == NULL) {
    AijinGuestOriginalWillFinish = method_getImplementation(will);
    class_replaceMethod(delegate, method_getName(will), (IMP)AijinGuestWillFinish,
                        method_getTypeEncoding(will));
  }
  if (did != NULL && AijinGuestOriginalDidFinish == NULL) {
    AijinGuestOriginalDidFinish = method_getImplementation(did);
    class_replaceMethod(delegate, method_getName(did), (IMP)AijinGuestDidFinish,
                        method_getTypeEncoding(did));
  }
}

static int AijinRunPlayBoxGuest(int argc, char *argv[]) {
  NSUInteger guestLaunchGeneration = ++AijinGuestLaunchGeneration;
  NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
  NSString *bundleIdentifier = [defaults
      stringForKey:@"TempMailPlayBoxGuestBundleIdentifier"];
  if (bundleIdentifier.length == 0) {
    bundleIdentifier = @"com.amk2ns2n9j.alan2is71";
  }
  NSString *storageIdentifier = [defaults
      stringForKey:@"TempMailPlayBoxGuestStorageIdentifier"];
  if (storageIdentifier.length == 0) {
    storageIdentifier = bundleIdentifier;
  }

  // The app data container UUID changes when a development build is replaced.
  // Rebuild paths from the current sandbox instead of trusting persisted
  // absolute paths from the previous installation.
  NSURL *documentsURL = [NSFileManager.defaultManager
      URLsForDirectory:NSDocumentDirectory
      inDomains:NSUserDomainMask].lastObject;
  NSString *bundlePath = [[documentsURL URLByAppendingPathComponent:
      [NSString stringWithFormat:@"Applications/%@.app", storageIdentifier]] path];
  NSDictionary *guestInfo = [NSDictionary dictionaryWithContentsOfFile:
      [bundlePath stringByAppendingPathComponent:@"Info.plist"]];
  if ([guestInfo[@"CFBundleExecutable"] isEqualToString:@"HBuilder"] &&
      !AijinSynchronizeHBuilderWebResources(bundlePath)) {
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }
  guestInfo = AijinPrepareHBuilderSceneManifest(bundlePath, guestInfo);
  if (guestInfo == nil) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed "
           "reason=scene_manifest");
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }
  NSString *executableName = guestInfo[@"CFBundleExecutable"];
  NSString *executablePath = executableName.length > 0
      ? [bundlePath stringByAppendingPathComponent:executableName]
      : @"";
  NSString *nivmPath = [bundlePath stringByAppendingPathComponent:@"rocketship.nivm"];

  [defaults setObject:bundlePath forKey:AijinGuestBundleKey];
  [defaults setObject:executablePath forKey:AijinGuestExecutableKey];
  [defaults setObject:nivmPath forKey:AijinGuestNIVMKey];

  if (bundlePath.length == 0 || executablePath.length == 0 || nivmPath.length == 0) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed reason=missing_paths");
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }

  NSFileManager *files = NSFileManager.defaultManager;
  if (![files fileExistsAtPath:bundlePath] ||
      ![files fileExistsAtPath:executablePath] ||
      ![files fileExistsAtPath:nivmPath]) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed reason=artifact_missing");
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }

  // dlopen with RTLD_GLOBAL, dyld callbacks, Objective-C class registration,
  // and later rebinding cannot be reliably undone. Make this flag sticky
  // before the first runtime load so every subsequent failure terminates the
  // contaminated process instead of returning to the host UI.
  AijinGuestRuntimeIrreversible = YES;
  if (!AijinLoadPlayBoxRuntime()) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed reason=runtime_load");
    return -1;
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-signals"]) {
    AijinInstallDiagnosticSignalHandler();
    AijinWriteDiagnosticStage("playbox_runtime_loaded");
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-preload-native-app"]) {
    void *nativeApp = AijinLoadFramework(@"App");
    NSLog(@"AIJIN_PLAYBOX_RUNTIME native_app_preload=%d", nativeApp != NULL);
    if (nativeApp == NULL) {
      return -1;
    }
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-preload-native-flutter"]) {
    void *nativeFlutter = AijinLoadFramework(@"Flutter");
    Class nativeChannelClass = NSClassFromString(@"FlutterMethodChannel");
    NSLog(@"AIJIN_PLAYBOX_RUNTIME native_flutter_preload=%d channel=%p image=%s",
          nativeFlutter != NULL, nativeChannelClass,
          nativeChannelClass == Nil
              ? "missing"
              : (class_getImageName(nativeChannelClass) ?: "unknown"));
    if (nativeFlutter == NULL || nativeChannelClass == Nil) {
      return -1;
    }
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-observe-connect"]) {
    AijinInstallConnectObservation();
  }
  // DYZB's translated plugin class cannot safely service the YunCeng method
  // channel after PBPlayerKit has installed its Flutter runtime.  The direct
  // device harness used to opt into the host bridge explicitly, but a normal
  // launcher self-restart has no diagnostic arguments.  Select the same
  // verified bridge from the persisted guest identity so the user-facing
  // Start button and the harness execute an identical runtime path.
  BOOL nativeYunCengPlugin =
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-native-yunceng-plugin"] ||
      [bundleIdentifier isEqualToString:@"ady.DYZB168dyzb.app"];
  if (nativeYunCengPlugin) {
    AijinInstallNativeYunCengPluginClass();
  }
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot bundle=%@", bundlePath.lastPathComponent);
  AijinWriteDiagnosticStage("identity_begin");
  AijinGuestIdentityInstallResult identityResult =
      AijinInstallGuestProcessIdentity(bundlePath, executablePath);
  if (identityResult == AijinGuestIdentityInstallResultUnsafe) {
    AijinWriteDiagnosticStage("identity_unsafe");
    NSLog(@"AIJIN_PLAYBOX_RUNTIME fallback_aborted "
           "reason=identity_transaction_unsafe");
    _exit(78);
  }
  if (identityResult != AijinGuestIdentityInstallResultSucceeded) {
    AijinWriteDiagnosticStage("identity_failed");
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed reason=identity_redirect");
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }
  AijinWriteDiagnosticStage("identity_ready");
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-bridge-kiwi-listener"]) {
    AijinInstallKiwiListenerBridge();
  }
  AijinWriteDiagnosticStage("nud_begin");
  AijinNUDGuestHooksInit();
  AijinWriteDiagnosticStage("nud_ready");
  AijinAdversarysHandler(AijinGuestCrashHandler);
  // adversarys_4 accepts an Objective-C class name (it resolves the class and
  // metaclass with objc_getClass/object_getClass), not a framework name.
  // PBPlayerKit already loads KiwiWrap and therefore owns the process-wide
  // `Kiwi` class; register that class so guest references are bound to the
  // compatible host implementation instead of a duplicate translated class.
  if (![NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-use-translated-kiwi"]) {
    AijinAdversarysClass("Kiwi");
  }
  if (nativeYunCengPlugin) {
    AijinAdversarysClass("FlutterYunCengKiwiPlugin");
  }
  AijinAdversarysClass("MJFoundation");
  AijinAdversarysClass("MJProperty");
  AijinAdversarysClass("MJPropertyKey");
  AijinAdversarysClass("MJPropertyType");

  BOOL looseRuntime =
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-run-dyzb-gq-loose"] ||
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-run-chungong-loose"];
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_open mode=%@",
        looseRuntime ? @"loose" : @"nivm");
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-signals"]) {
    AijinInstallDiagnosticSignalHandler();
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-bridge-guest-callbacks"] ||
      [NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-bridge-dispatch-once-import"]) {
    AijinInstallGuestCallbackBridges();
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-terminate"]) {
    AijinInstallDiagnosticTerminateHandler();
  }
  if (looseRuntime && !AijinPreloadLooseGuestImages(bundlePath)) {
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }
  // Test-only LLDB synchronization point.  Starting the process suspended at
  // dyld changes the earliest framework-loading timing on a physical device.
  // Stop here instead, after PBPlayerKit/adversarys and libc++abi are loaded,
  // so exception breakpoints can be resolved before the guest parser runs.
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-debug-stop-before-guest"]) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME debug_stop_before_guest");
    raise(SIGSTOP);
    NSLog(@"AIJIN_PLAYBOX_RUNTIME debug_resumed_before_guest");
  }
  AijinStartDiagnosticFileBurst(@"guest_open");
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-focused-result"]) {
    AijinStartDiagnosticFocusedBurst();
  }
  AijinLogDiagnosticMemory(@"before_guest_open");
  void *guest = looseRuntime
      ? AijinAdversarysOpenLoose(executablePath.fileSystemRepresentation)
      : AijinAdversarysOpen(executablePath.fileSystemRepresentation,
                            nivmPath.fileSystemRepresentation);
  if (guest == NULL) {
    const char *error = AijinAdversarysError();
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_open_failed error=%s",
          error == NULL ? "unknown" : error);
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }
  // Test-only LLDB synchronization point after adversarys has parsed every
  // Mach-O and resolved its native imports.  This avoids putting a global
  // dlopen/dlsym breakpoint on the expensive guest_open phase when diagnosing
  // Flutter's later App.framework snapshot lookup.
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-debug-stop-after-guest-open"]) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME debug_stop_after_guest_open");
    raise(SIGSTOP);
    NSLog(@"AIJIN_PLAYBOX_RUNTIME debug_resumed_after_guest_open");
  }
  if ([bundleIdentifier isEqualToString:@"com.cg.client.pro"] &&
      !AijinInstallChungongKingfisherWrapperMetadataCompatibility()) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed "
          "reason=kingfisher_wrapper_metadata");
    return -1;
  }
  if ([bundleIdentifier isEqualToString:@"com.cg.client.pro"] &&
      !AijinInstallChungongKingfisherImageResourceMetadataCompatibility()) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed "
          "reason=kingfisher_image_resource_metadata");
    return -1;
  }
  if ([bundleIdentifier isEqualToString:@"com.cg.client.pro"] &&
      !AijinInstallChungongKingfisherDownloadTaskMetadataCompatibility()) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed "
          "reason=kingfisher_download_task_metadata");
    return -1;
  }
  if ([bundleIdentifier isEqualToString:@"com.cg.client.pro"] &&
      !AijinRegisterMappedGuestSwiftMetadata()) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_boot_failed "
          "reason=swift_metadata_registration");
    return -1;
  }
  if ([bundleIdentifier isEqualToString:@"com.cg.client.pro"]) {
    AijinInstallChungongUIKitCompatibility();
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-bridge-dyzb-kiwi-plugin"]) {
    AijinInstallDyzbKiwiPluginBridge();
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-prepare-dyzb-kiwi"]) {
    AijinInstallDyzbKiwiPrepareBridge();
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-bridge-dyzb-kiwi-class"]) {
    AijinInstallDyzbKiwiClassBridge();
  }

  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-signals"]) {
    static const char *const snapshotSymbols[] = {
      "kDartVmSnapshotData",
      "kDartVmSnapshotInstructions",
      "kDartIsolateSnapshotData",
      "kDartIsolateSnapshotInstructions",
    };
    for (NSUInteger index = 0;
         index < sizeof(snapshotSymbols) / sizeof(snapshotSymbols[0]);
         index += 1) {
      const char *symbol = snapshotSymbols[index];
      void *guestSymbol = AijinAdversarysSymbol(guest, symbol);
      void *processSymbol = dlsym(RTLD_DEFAULT, symbol);
      NSLog(@"AIJIN_DIAGNOSTIC_SNAPSHOT symbol=%s guest=%p process=%p",
            symbol, guestSymbol, processSymbol);
    }
    NSString *appFrameworkPath = [bundlePath
        stringByAppendingPathComponent:@"Frameworks/App.framework/App"];
    NSLog(@"AIJIN_DIAGNOSTIC_SNAPSHOT app_path=%@ exists=%d bundle_resource=%@",
          appFrameworkPath,
          [NSFileManager.defaultManager fileExistsAtPath:appFrameworkPath],
          [NSBundle.mainBundle pathForResource:@"Frameworks/App.framework"
                                       ofType:@""]);
  }

  typedef int (*GuestMain)(int, char **);
  GuestMain guestMain = (GuestMain)AijinAdversarysSymbol(guest, "main");
  if (guestMain == NULL) {
    const char *error = AijinAdversarysError();
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_main_missing error=%s",
          error == NULL ? "unknown" : error);
    [defaults setBool:NO forKey:AijinGuestModeKey];
    return -1;
  }

#if defined(AIJIN_HBUILDER_DIAGNOSTICS)
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-hbuilder"]) {
    AijinInstallHBuilderDiagnostics();
  }
#endif

  if (AijinInProcessGuestBootstrap) {
    UIApplication *application = UIApplication.sharedApplication;
    BOOL isChungongGuest =
        [bundleIdentifier isEqualToString:@"com.cg.client.pro"];
    NSString *mainStoryboardName = guestInfo[@"UIMainStoryboardFile"];
    BOOL isHBuilderGuest =
        [executableName isEqualToString:@"HBuilder"] &&
        mainStoryboardName.length == 0;
    BOOL guestBuildsOwnWindow = isChungongGuest || isHBuilderGuest;
    BOOL preserveHostApplicationDelegate = guestBuildsOwnWindow ||
        [bundleIdentifier isEqualToString:@"com.laodeng.worldcupapp"];
    NSString *swiftModule = guestInfo[@"CFBundleExecutable"];
    NSMutableArray<NSString *> *delegateClassNames =
        [NSMutableArray array];
    if (swiftModule.length > 0) {
      [delegateClassNames addObject:
          [NSString stringWithFormat:@"%@.AppDelegate", swiftModule]];
      NSUInteger moduleByteLength =
          [swiftModule lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
      [delegateClassNames addObject:
          [NSString stringWithFormat:@"_TtC%lu%@11AppDelegate",
                                     (unsigned long)moduleByteLength,
                                     swiftModule]];
    }
    [delegateClassNames addObject:@"AppDelegate"];
    Class delegateClass = Nil;
    NSString *delegateClassName = nil;
    for (NSString *candidateName in delegateClassNames) {
      delegateClass = NSClassFromString(candidateName);
      if (delegateClass == Nil) {
        delegateClass = objc_getClass(candidateName.UTF8String);
      }
      if (delegateClass != Nil) {
        delegateClassName = candidateName;
        break;
      }
    }
    if (delegateClass == Nil) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME in_process_failed "
            "reason=delegate_missing candidates=%@",
            delegateClassNames);
      return -1;
    }
    NSLog(@"AIJIN_PLAYBOX_RUNTIME in_process_delegate class=%@ candidate=%@",
          NSStringFromClass(delegateClass), delegateClassName);
    id hostDelegate = application.delegate;
    UIWindow *hostWindow = nil;
    if ([hostDelegate respondsToSelector:@selector(window)]) {
      hostWindow = ((id (*)(id, SEL))objc_msgSend)(hostDelegate,
                                                   @selector(window));
    }
    if (hostWindow == nil) {
      hostWindow = AijinCurrentForegroundWindow(application);
    }
    AijinHostApplicationDelegate = hostDelegate;
    AijinHostApplicationWindow = hostWindow;
    AijinHostRootViewController = hostWindow.rootViewController;
    AijinHostWindowWasHidden = hostWindow.hidden;
    AijinHostWindowWasKey = hostWindow.isKeyWindow;
    AijinHostApplicationSurfaceCaptured = hostWindow != nil;
    NSLog(@"AIJIN_PLAYBOX_RUNTIME host_window_captured delegate=%@ window=%@ "
          "key=%d hidden=%d",
          NSStringFromClass([hostDelegate class]),
          NSStringFromClass(hostWindow.class), hostWindow.isKeyWindow,
          hostWindow.hidden);
    if (hostWindow == nil) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME in_process_failed reason=host_window");
      return -1;
    }
    NSLog(@"AIJIN_PLAYBOX_RUNTIME delegate_alloc_begin class=%@",
          NSStringFromClass(delegateClass));
    id guestDelegate = [delegateClass alloc];
    NSLog(@"AIJIN_PLAYBOX_RUNTIME delegate_alloc_end object=%p class=%@",
          (__bridge void *)guestDelegate,
          guestDelegate == nil ? @"nil" : NSStringFromClass([guestDelegate class]));
    NSLog(@"AIJIN_PLAYBOX_RUNTIME delegate_init_begin object=%p",
          (__bridge void *)guestDelegate);
    guestDelegate = [guestDelegate init];
    NSLog(@"AIJIN_PLAYBOX_RUNTIME delegate_init_end object=%p class=%@",
          (__bridge void *)guestDelegate,
          guestDelegate == nil ? @"nil" : NSStringFromClass([guestDelegate class]));
    SEL setDelegateSelector = NSSelectorFromString(@"setDelegate:");
    if (guestDelegate == nil ||
        ![application respondsToSelector:setDelegateSelector]) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME in_process_failed reason=delegate_setter");
      return -1;
    }
    AijinInProcessGuestDelegate = guestDelegate;
    if (preserveHostApplicationDelegate) {
      // Keep the launcher as UIApplication's system delegate. UIKit/FrontBoard
      // associates the active scene and its key window with that delegate;
      // replacing it after launch makes the process terminate. The guest
      // lifecycle is driven explicitly below and the guest delegate is retained
      // independently in AijinInProcessGuestDelegate.
      NSLog(@"AIJIN_PLAYBOX_RUNTIME application_delegate_preserved class=%@",
            NSStringFromClass([hostDelegate class]));
    } else {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME application_delegate_set_begin class=%@",
            NSStringFromClass([guestDelegate class]));
      ((void (*)(id, SEL, id))objc_msgSend)(application, setDelegateSelector,
                                            guestDelegate);
      NSLog(@"AIJIN_PLAYBOX_RUNTIME application_delegate_set_end class=%@",
            NSStringFromClass([application.delegate class]));
    }

    // UIApplicationMain normally creates UIMainStoryboardFile and assigns its
    // window before calling the app delegate. Because the Aijin launcher has
    // already completed that work for its own delegate, reproduce the same
    // ordering for the selected guest.
    UIViewController *guestRoot = nil;
    UIWindow *guestWindow = nil;
    if (!guestBuildsOwnWindow) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME storyboard_create_begin bundle=%@ path=%@",
            AijinGuestMainBundle.bundleIdentifier,
            AijinGuestMainBundle.bundlePath);
      UIStoryboard *storyboard =
          [UIStoryboard storyboardWithName:mainStoryboardName
                                    bundle:AijinGuestMainBundle];
      NSLog(@"AIJIN_PLAYBOX_RUNTIME storyboard_create_end storyboard=%p",
            (__bridge void *)storyboard);
      NSLog(@"AIJIN_PLAYBOX_RUNTIME storyboard_instantiate_begin");
      guestRoot = [storyboard instantiateInitialViewController];
      NSLog(@"AIJIN_PLAYBOX_RUNTIME storyboard_instantiate_end root=%p class=%@",
            (__bridge void *)guestRoot,
            guestRoot == nil ? @"nil" : NSStringFromClass([guestRoot class]));
      if (hostWindow.windowScene != nil) {
        NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_window_create_begin mode=scene");
        guestWindow =
            [[UIWindow alloc] initWithWindowScene:hostWindow.windowScene];
      } else {
        NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_window_create_begin mode=frame");
        guestWindow =
            [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
      }
      NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_window_create_end window=%p",
            (__bridge void *)guestWindow);
      guestWindow.rootViewController = guestRoot;
      NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_window_root_set class=%@",
            NSStringFromClass([guestRoot class]));
      SEL setWindowSelector = @selector(setWindow:);
      if ([guestDelegate respondsToSelector:setWindowSelector]) {
        NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_delegate_window_set_begin");
        ((void (*)(id, SEL, id))objc_msgSend)(guestDelegate,
                                              setWindowSelector, guestWindow);
        NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_delegate_window_set_end");
      }
    } else if (isChungongGuest) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_window_mode=chungong_delegate");
      // The Chungong AppDelegate allocates and assigns its UIWindow before
      // makeKeyAndVisible. Pre-instantiating the storyboard here schedules its
      // translated lifecycle methods while didFinish is still running and
      // makes the non-reentrant guest interpreter reuse its return state.
      AijinInstallChungongUIKitCompatibility();
      AijinPrewarmChungongUIViewControllerMetadata();
      AijinPrewarmChungongKingfisherWrapperMetadata();
      AijinInstallChungongObjectMapperCompatibility();
      AijinInstallChungongObjectMapperMetadataCompatibility();
      AijinInstallChungongAppearanceEnumCompatibility();
      AijinPrewarmChungongModelWitness();
      AijinInstallChungongModelValueWitnessCompatibility();
    } else {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_window_mode=hbuilder_delegate");
    }

    NSDictionary *launchOptions = @{};
    SEL willFinish = @selector(application:willFinishLaunchingWithOptions:);
    SEL didFinish = @selector(application:didFinishLaunchingWithOptions:);
    BOOL willResult = YES;
    BOOL didResult = YES;
    BOOL deferredGuestWindowVisibility =
        isChungongGuest ? AijinBeginGuestWindowVisibilityDeferral() : NO;
    if ([guestDelegate respondsToSelector:willFinish]) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME will_finish_begin");
      willResult = ((BOOL (*)(id, SEL, id, id))objc_msgSend)(
          guestDelegate, willFinish, application, launchOptions);
      NSLog(@"AIJIN_PLAYBOX_RUNTIME will_finish_end result=%d", willResult);
    }
    if (willResult && [guestDelegate respondsToSelector:didFinish]) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME did_finish_begin");
      didResult = ((BOOL (*)(id, SEL, id, id))objc_msgSend)(
          guestDelegate, didFinish, application, launchOptions);
      NSLog(@"AIJIN_PLAYBOX_RUNTIME did_finish_end result=%d", didResult);
    }
    AijinEndGuestWindowVisibilityDeferral(deferredGuestWindowVisibility,
                                           !guestBuildsOwnWindow);
    SEL windowSelector = @selector(window);
    if ([guestDelegate respondsToSelector:windowSelector]) {
      id delegateWindow = ((id (*)(id, SEL))objc_msgSend)(guestDelegate,
                                                          windowSelector);
      if (delegateWindow != nil) {
        guestWindow = delegateWindow;
      }
    }
    if (isHBuilderGuest && guestWindow != nil &&
        hostWindow.windowScene != nil &&
        guestWindow.windowScene != hostWindow.windowScene) {
      guestWindow.windowScene = hostWindow.windowScene;
      NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_scene_attached scene=%@",
            hostWindow.windowScene.session.persistentIdentifier);
    }
    AijinInProcessGuestWindow =
        isChungongGuest ? hostWindow : guestWindow;
    if (isHBuilderGuest) {
      AijinInProcessGuestRootController = guestWindow.rootViewController;
    }
    SEL becameActive = @selector(applicationDidBecomeActive:);
    BOOL inProcessLaunchSucceeded = willResult && didResult &&
        guestWindow != nil;
    if (isChungongGuest) {
      inProcessLaunchSucceeded = inProcessLaunchSucceeded &&
          deferredGuestWindowVisibility &&
          AijinOriginalSetRootViewController != NULL;
    } else if (isHBuilderGuest) {
      inProcessLaunchSucceeded = inProcessLaunchSucceeded &&
          guestWindow.rootViewController != nil &&
          hostWindow.windowScene != nil &&
          guestWindow.windowScene == hostWindow.windowScene;
    }
    NSBundle *guestBundleForLaunch = AijinGuestMainBundle;
    if (isChungongGuest && inProcessLaunchSucceeded) {
      // UIKit activates the new root controller synchronously from
      // makeKeyAndVisible. Running that lifecycle while the translated guest
      // launch callback is unwinding makes the non-reentrant interpreter race
      // its dispatch/reachability callbacks. Move the entire window handoff to
      // a later main-runloop turn and retain the guest window independently of
      // the translated AppDelegate property.
      NSLog(@"AIJIN_PLAYBOX_RUNTIME window_activation_scheduled window=%@",
            NSStringFromClass(guestWindow.class));
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                   (int64_t)(0.20 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
        if (guestLaunchGeneration != AijinGuestLaunchGeneration) {
          NSLog(@"AIJIN_PLAYBOX_RUNTIME window_activation_cancelled "
                 "generation=%lu current=%lu",
                (unsigned long)guestLaunchGeneration,
                (unsigned long)AijinGuestLaunchGeneration);
          return;
        }
        UIWindow *deferredGuestWindow = nil;
        UIViewController *deferredGuestController =
            AijinTakeDeferredGuestRootController(&deferredGuestWindow);
        UIViewController *nativeContainer = [[UIViewController alloc] init];
        nativeContainer.view.backgroundColor = UIColor.blackColor;
        UIImage *launchImage = [UIImage imageNamed:@"ic_welcome_m"
                                          inBundle:guestBundleForLaunch
                         compatibleWithTraitCollection:nil];
        UIImageView *launchImageView = [[UIImageView alloc]
            initWithFrame:nativeContainer.view.bounds];
        launchImageView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        launchImageView.contentMode = UIViewContentModeScaleAspectFill;
        launchImageView.clipsToBounds = YES;
        launchImageView.image = launchImage;
        [nativeContainer.view addSubview:launchImageView];
        UIActivityIndicatorView *launchIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        launchIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        launchIndicator.color = UIColor.whiteColor;
        [launchIndicator startAnimating];
        [nativeContainer.view addSubview:launchIndicator];
        [NSLayoutConstraint activateConstraints:@[
          [launchIndicator.centerXAnchor
              constraintEqualToAnchor:nativeContainer.view.centerXAnchor],
          [launchIndicator.bottomAnchor
              constraintEqualToAnchor:nativeContainer.view.safeAreaLayoutGuide
                                          .bottomAnchor
                         constant:-36.0],
        ]];
        NSLog(@"AIJIN_PLAYBOX_RUNTIME native_container_apply_begin");
        ((void (*)(id, SEL, id))AijinOriginalSetRootViewController)(
            hostWindow, @selector(setRootViewController:), nativeContainer);
        hostWindow.hidden = NO;
        NSLog(@"AIJIN_PLAYBOX_RUNTIME native_container_applied window=%@",
              NSStringFromClass(hostWindow.class));
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(0.10 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
          if (guestLaunchGeneration != AijinGuestLaunchGeneration) {
            NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_cancelled "
                   "generation=%lu current=%lu",
                  (unsigned long)guestLaunchGeneration,
                  (unsigned long)AijinGuestLaunchGeneration);
            return;
          }
          NSLog(@"AIJIN_PLAYBOX_RUNTIME native_launch_surface_ready image=%d "
                "guest_controller=%@",
                launchImage != nil,
                NSStringFromClass(deferredGuestController.class));
          NSLog(@"AIJIN_PLAYBOX_RUNTIME in_process_ready delegate=%@ will=%d "
                "did=%d window=%@ root=%@ guest_root=%@",
                NSStringFromClass(delegateClass), willResult, didResult,
                NSStringFromClass([hostWindow class]),
                NSStringFromClass([[hostWindow rootViewController] class]),
                NSStringFromClass(deferredGuestController.class));
          Class tabControllerClass =
              NSClassFromString(@"Seal.ApplicationTabBarViewController");
          if (tabControllerClass == Nil) {
            tabControllerClass = objc_getClass(
                "_TtC4Seal31ApplicationTabBarViewController");
          }
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_begin class=%@",
                NSStringFromClass(tabControllerClass));
          if (tabControllerClass == Nil) {
            NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_failed "
                  "reason=class_missing");
            _exit(79);
          }
          SEL tabInitializer = @selector(initWithNibName:bundle:);
          Method nativeTabInitializer = class_getInstanceMethod(
              class_getSuperclass(tabControllerClass), tabInitializer);
          if (nativeTabInitializer == NULL) {
            NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_failed "
                  "reason=super_initializer_missing");
            _exit(79);
          }
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_alloc_begin");
          id allocatedTabController = [tabControllerClass alloc];
          if (allocatedTabController == nil) {
            NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_failed "
                   "reason=allocation");
            _exit(79);
          }
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_alloc_end object=%@",
                NSStringFromClass([allocatedTabController class]));
          Class nativeTabControllerClass =
              class_getSuperclass(tabControllerClass);
          Class allocatedTabControllerClass = object_setClass(
              allocatedTabController, nativeTabControllerClass);
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_native_isa_applied old=%@ new=%@",
                NSStringFromClass(allocatedTabControllerClass),
                NSStringFromClass([allocatedTabController class]));
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_super_init_begin imp=%p",
                method_getImplementation(nativeTabInitializer));
          UIViewController *tabController =
              ((id (*)(id, SEL, id, id))method_getImplementation(
                  nativeTabInitializer))(allocatedTabController,
                                         tabInitializer, nil, nil);
          if (tabController != nil) {
            object_setClass(tabController, tabControllerClass);
          } else {
            NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_failed "
                   "reason=initialization");
            _exit(79);
          }
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_super_init_end object=%@",
                NSStringFromClass(tabController.class));
          AijinInProcessGuestRootController = tabController;
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_end controller=%@ "
                "super=%@ view_loaded=%d",
                NSStringFromClass(tabController.class),
                NSStringFromClass(class_getSuperclass(tabControllerClass)),
                tabController.isViewLoaded);
          Method guestTabViewDidLoad = class_getInstanceMethod(
              tabControllerClass, @selector(viewDidLoad));
          IMP guestTabViewDidLoadImplementation =
              guestTabViewDidLoad == NULL
                  ? NULL
                  : method_getImplementation(guestTabViewDidLoad);
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_view_did_load_begin imp=%p",
                guestTabViewDidLoadImplementation);
          if (guestTabViewDidLoadImplementation == NULL) {
            NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_bootstrap_failed "
                   "reason=view_did_load_missing");
            _exit(79);
          }
          object_setClass(tabController, nativeTabControllerClass);
          ((void (*)(id, SEL))guestTabViewDidLoadImplementation)(
              tabController, @selector(viewDidLoad));
          object_setClass(tabController, tabControllerClass);
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_view_did_load_end children=%lu "
                "subviews=%lu",
                (unsigned long)tabController.childViewControllers.count,
                (unsigned long)tabController.view.subviews.count);
          if (guestLaunchGeneration != AijinGuestLaunchGeneration) {
            NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_handoff_cancelled "
                   "generation=%lu current=%lu",
                  (unsigned long)guestLaunchGeneration,
                  (unsigned long)AijinGuestLaunchGeneration);
            return;
          }
          ((void (*)(id, SEL, id))AijinOriginalSetRootViewController)(
              hostWindow, @selector(setRootViewController:), tabController);
          hostWindow.hidden = NO;
          if ([guestDelegate respondsToSelector:becameActive]) {
            ((void (*)(id, SEL, id))objc_msgSend)(
                guestDelegate, becameActive, application);
          }
          AijinInstallGuestFloatingControl(hostWindow);
          AijinMarkInProcessGuestLifecycleActive();
          NSLog(@"AIJIN_PLAYBOX_RUNTIME tab_handoff_complete root=%@",
                NSStringFromClass(hostWindow.rootViewController.class));
        });
      });
    } else if (isChungongGuest) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME window_activation_not_scheduled "
             "will=%d did=%d window=%@",
            willResult, didResult, NSStringFromClass(guestWindow.class));
    } else if (isHBuilderGuest && inProcessLaunchSucceeded) {
      [guestWindow makeKeyAndVisible];
      AijinInstallGuestFloatingControl(guestWindow);
      hostWindow.hidden = YES;
      if ([guestDelegate respondsToSelector:becameActive]) {
        ((void (*)(id, SEL, id))objc_msgSend)(guestDelegate, becameActive,
                                              application);
      }
      AijinMarkInProcessGuestLifecycleActive();
      NSLog(@"AIJIN_PLAYBOX_RUNTIME in_process_ready mode=hbuilder "
             "delegate=%@ will=%d did=%d window=%@ root=%@",
            NSStringFromClass(delegateClass), willResult, didResult,
            NSStringFromClass(guestWindow.class),
            NSStringFromClass(guestWindow.rootViewController.class));
    } else if (isHBuilderGuest) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME hbuilder_window_failed will=%d did=%d "
             "window=%@ root=%@ host_scene=%@ guest_scene=%@",
            willResult, didResult, NSStringFromClass(guestWindow.class),
            NSStringFromClass(guestWindow.rootViewController.class),
            hostWindow.windowScene, guestWindow.windowScene);
    } else {
      [guestWindow makeKeyAndVisible];
      AijinInstallGuestFloatingControl(guestWindow);
      hostWindow.hidden = YES;
      if (didResult && [guestDelegate respondsToSelector:becameActive]) {
        ((void (*)(id, SEL, id))objc_msgSend)(guestDelegate, becameActive,
                                              application);
      }
      AijinMarkInProcessGuestLifecycleActive();
      NSLog(@"AIJIN_PLAYBOX_RUNTIME in_process_ready delegate=%@ will=%d "
            "did=%d window=%@ root=%@",
            NSStringFromClass(delegateClass), willResult, didResult,
            NSStringFromClass([guestWindow class]),
            NSStringFromClass([[guestWindow rootViewController] class]));
    }
    AijinScheduleGuestScreenshot(5, @"inprocess-guest-screen-05.png");
    AijinScheduleGuestScreenshot(15, @"inprocess-guest-screen-15.png");
    AijinScheduleGuestScreenshot(30, @"inprocess-guest-screen-30.png");
    return inProcessLaunchSucceeded ? 0 : -1;
  }

  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_main_start");
  AijinLogDiagnosticMemory(@"before_guest_main");
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-signals"]) {
    AijinInstallDiagnosticSignalHandler();
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-samples"]) {
    AijinInstallDiagnosticSampler();
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-diagnostic-thread-samples"]) {
    AijinScheduleDiagnosticThreadSampler();
    AijinInspectGuestRegistration(2);
    AijinInspectGuestRegistration(10);
  }
  if ([NSProcessInfo.processInfo.arguments
          containsObject:@"--aijin-debug-stop-before-guest-main"]) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME debug_wait_before_guest_main");
    sleep(12);
  }
  if ([executableName isEqualToString:@"HBuilder"]) {
    AijinFilterHBuilderHostLaunchIntent();
    AijinInstallHBuilderFileManager();
  }
  char *originalArgumentZero = argv[0];
  char *guestArgumentZero = strdup(executablePath.fileSystemRepresentation);
  if (guestArgumentZero == NULL) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_main_failed reason=argv0_allocation");
    return -1;
  }
  argv[0] = guestArgumentZero;
  AijinScheduleGuestScreenshot(5, @"guest-screen-05.png");
  AijinScheduleGuestScreenshot(15, @"guest-screen-15.png");
  AijinScheduleGuestScreenshot(30, @"guest-screen-30.png");
  AijinScheduleGuestScreenshot(60, @"guest-screen-60.png");
  AijinScheduleGuestScreenshot(120, @"guest-screen-120.png");
  AijinScheduleGuestScreenshot(180, @"guest-screen-180.png");
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC),
                 dispatch_get_main_queue(), ^{
    [NSFileManager.defaultManager
        removeItemAtURL:AijinPlayBoxContinuationMarkerURL()
                  error:nil];
  });
  int result = guestMain(argc, argv);
  if (AijinGuestOriginalDefaultFileManager != NULL) {
    Method method = class_getClassMethod(NSFileManager.class, @selector(defaultManager));
    method_setImplementation(method, AijinGuestOriginalDefaultFileManager);
    AijinGuestOriginalDefaultFileManager = NULL;
    AijinHBuilderFileManager = nil;
  }
  argv[0] = originalArgumentZero;
  free(guestArgumentZero);
  NSLog(@"AIJIN_PLAYBOX_RUNTIME guest_main_returned code=%d", result);
  return result;
}

int AijinLaunchSelectedPlayBoxGuestInProcess(void) {
  if (!AijinAcquireGuestRuntimeLaunchClaim()) {
    NSLog(@"AIJIN_PLAYBOX_RUNTIME launch_ignored reason=already_active");
    return 0;
  }
  AijinResetInProcessGuestLifecycle();
  AijinGuestRuntimeIrreversible = NO;
  AijinInProcessGuestBootstrap = YES;
  const char *executable = NSBundle.mainBundle.executablePath.fileSystemRepresentation;
  char *arguments[] = {(char *)executable, NULL};
  int result = AijinRunPlayBoxGuest(1, arguments);
  AijinInProcessGuestBootstrap = NO;
  if (result < 0) {
    if (AijinGuestRuntimeIrreversible) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME fallback_aborted "
             "reason=irreversible_runtime_state");
      _exit(79);
    }
    if (!AijinRestorePreviousProcessIdentity()) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME fallback_aborted reason=identity_restore");
      _exit(78);
    }
    if (!AijinRestoreHostApplicationSurface()) {
      NSLog(@"AIJIN_PLAYBOX_RUNTIME fallback_aborted reason=surface_restore");
      _exit(80);
    }
    AijinReleaseGuestRuntimeLaunchClaim();
  }
  return result;
}

int main(int argc, char *argv[]) {
  @autoreleasepool {
    AijinHostBundle = NSBundle.mainBundle;
    NSArray<NSString *> *processArguments = NSProcessInfo.processInfo.arguments;
    NSUInteger decryptProbeIndex =
        [processArguments indexOfObject:@"--aijin-probe-lnkiwi-decrypt"];
    if (decryptProbeIndex != NSNotFound) {
      if (decryptProbeIndex + 1 >= processArguments.count) {
        NSLog(@"AIJIN_LNKIWI_DECRYPT error=missing_argument");
        return 64;
      }
      if (AijinLoadFramework(@"PBPlayerKit") == NULL) {
        NSLog(@"AIJIN_LNKIWI_DECRYPT error=framework_load_failed");
        return 65;
      }
      NSString *encrypted = processArguments[decryptProbeIndex + 1];
      AijinProbeLNKiwiDecrypt(encrypted.UTF8String);
      return 0;
    }

    if ([NSProcessInfo.processInfo.arguments
            containsObject:@"--aijin-playbox-developer"]) {
      return UIApplicationMain(
          argc, argv, nil,
          NSStringFromClass(NSClassFromString(@"AijinHostDelegate")));
    }

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSURL *qaReturnMarker = [AijinPlayBoxContinuationMarkerURL().URLByDeletingLastPathComponent
        URLByAppendingPathComponent:@"qa-floating-return"];
    if ([processArguments containsObject:@"--aijin-test-floating-return"]) {
      [NSFileManager.defaultManager createDirectoryAtURL:qaReturnMarker.URLByDeletingLastPathComponent
                           withIntermediateDirectories:YES attributes:nil error:nil];
      [@"1" writeToURL:qaReturnMarker atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    if ([processArguments containsObject:@"--aijin-stop-capture"]) {
      [defaults removeObjectForKey:@"TempMailQAFloatingReturn"];
      [NSFileManager.defaultManager removeItemAtURL:qaReturnMarker error:nil];
      [defaults synchronize];
    }

    if ([defaults boolForKey:@"TempMailQACaptureSurface"]) {
      NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TempMailTest/qa-runtime.log"];
      FILE *log = fopen(logPath.fileSystemRepresentation, "a");
      if (log != NULL) {
        dup2(fileno(log), STDERR_FILENO);
        setvbuf(stderr, NULL, _IOLBF, 0);
        fclose(log);
      }
    }

    BOOL installCommand = NO;
    for (NSString *argument in processArguments) {
      if ([argument hasPrefix:@"--aijin-install-"]) {
        installCommand = YES;
        break;
      }
    }
    if (installCommand ||
        [processArguments containsObject:@"--aijin-clear-launch-state"]) {
      [defaults removeObjectForKey:AijinRuntimeLaunchTokenKey];
      [defaults removeObjectForKey:AijinGuestLaunchTokenKey];
      [defaults removeObjectForKey:AijinGuestModeKey];
      [defaults synchronize];
      [NSFileManager.defaultManager
          removeItemAtURL:AijinPlayBoxContinuationMarkerURL()
                    error:nil];
      NSLog(@"AIJIN_RUNTIME launch_state_cleared reason=%@",
            installCommand ? @"install" : @"explicit");
    }
    // Deterministic real-device harness: bypass the launcher/relaunch hop so
    // devicectl can keep stdout attached while a selected PlayBox guest boots.
    // These arguments are test-only one-shot commands; normal UI launches keep
    // using AijinLauncherViewController's relaunch flow.
    NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *>
        *directPlayBoxGuests = @{
      @"--aijin-run-tianya-348-direct": @{
        @"bundle": @"com.laodeng.worldcupapp",
        @"storage": @"tianya_348",
      },
      @"--aijin-run-adult-douyin-direct": @{
        @"bundle": @"com.amk2ns2n9j.alan2is71",
        @"storage": @"com.amk2ns2n9j.alan2is71",
      },
      @"--aijin-run-dyzb-gq-direct": @{
        @"bundle": @"ady.DYZB168dyzb.app",
        @"storage": @"dyzb_gq",
      },
      @"--aijin-run-dyzb-gq-loose": @{
        @"bundle": @"ady.DYZB168dyzb.app",
        @"storage": @"dyzb_gq",
      },
      @"--aijin-run-dyzb-tf-direct": @{
        @"bundle": @"ady.DYZB168dyzb.app",
        @"storage": @"dyzb_tf",
      },
      @"--aijin-run-chungong-direct": @{
        @"bundle": @"com.cg.client.pro",
        @"storage": @"chungong_3_9_1",
      },
      @"--aijin-run-chungong-loose": @{
        @"bundle": @"com.cg.client.pro",
        @"storage": @"chungong_3_9_1",
      },
      @"--aijin-run-ig-xiongmao-direct": @{
        @"bundle": @"com.igvideo.jingdong",
        @"storage": @"ig_xiongmao",
      },
    };
    for (NSString *argument in directPlayBoxGuests) {
      if (![NSProcessInfo.processInfo.arguments containsObject:argument]) {
        continue;
      }
      NSDictionary<NSString *, NSString *> *guest =
          directPlayBoxGuests[argument];
      [defaults setObject:@"playbox" forKey:AijinRuntimeKindKey];
      [defaults setObject:NSUUID.UUID.UUIDString
                   forKey:AijinRuntimeLaunchTokenKey];
      [defaults setObject:guest[@"bundle"]
                   forKey:@"TempMailPlayBoxGuestBundleIdentifier"];
      [defaults setObject:guest[@"storage"]
                   forKey:@"TempMailPlayBoxGuestStorageIdentifier"];
      [defaults synchronize];
      NSLog(@"AIJIN_PLAYBOX_RUNTIME direct_harness guest=%@",
            guest[@"storage"]);
      break;
    }
    NSString *launchToken = [defaults stringForKey:AijinRuntimeLaunchTokenKey];
    NSString *runtimeKind = [defaults stringForKey:AijinRuntimeKindKey];
    if (launchToken.length == 0) {
      launchToken = [defaults stringForKey:AijinGuestLaunchTokenKey];
      if (launchToken.length > 0) {
        runtimeKind = @"playbox";
      }
    }
    if (launchToken.length == 0 &&
        AijinConsumeFreshPlayBoxContinuationMarker()) {
      // The supported HBuilder guest performs one internal relaunch after its
      // resource/bootstrap phase. PBPlayerKit also restores a preferences
      // snapshot during that transition, so this one-use Documents marker is
      // intentionally independent of NSUserDefaults.
      launchToken = NSUUID.UUID.UUIDString;
      runtimeKind = @"playbox";
    }

    // Older builds persisted guest mode forever, which made every normal app
    // launch jump straight into the guest. Guest launch is now a one-shot
    // command: consume it before entering the runtime, so the next Aijin open
    // always returns to the launcher even if the guest crashes.
    [defaults removeObjectForKey:AijinGuestModeKey];
    if (launchToken.length > 0) {
      [defaults removeObjectForKey:AijinRuntimeLaunchTokenKey];
      [defaults removeObjectForKey:AijinGuestLaunchTokenKey];
      [defaults synchronize];
      BOOL playBoxRuntime = ![runtimeKind isEqualToString:@"flutter"];
      if (playBoxRuntime && !AijinAcquireGuestRuntimeLaunchClaim()) {
        NSLog(@"AIJIN_PLAYBOX_RUNTIME launch_aborted reason=already_active");
        return 81;
      }
      if (playBoxRuntime) {
        AijinGuestRuntimeIrreversible = NO;
      }
      int result = playBoxRuntime
          ? AijinRunPlayBoxGuest(argc, argv)
          : AijinRunFlutterGuest(argc, argv);
      if (result >= 0) {
        return result;
      }
      if (playBoxRuntime) {
        if (AijinGuestRuntimeIrreversible) {
          NSLog(@"AIJIN_PLAYBOX_RUNTIME fallback_aborted "
                 "reason=irreversible_runtime_state");
          return 79;
        }
        if (!AijinRestorePreviousProcessIdentity()) {
          NSLog(@"AIJIN_PLAYBOX_RUNTIME fallback_aborted "
                 "reason=identity_restore");
          return 78;
        }
        AijinReleaseGuestRuntimeLaunchClaim();
      }
    }
    return UIApplicationMain(argc, argv, nil,
                             NSStringFromClass(NSClassFromString(@"AijinHostDelegate")));
  }
}
