require 'formula'

class Vlc < Formula
  # This is a HEAD only formula. the VLC guys say their tarballs are currently having build problems
  homepage 'http://www.videolan.org/vlc'
  head 'git://git.videolan.org/vlc/vlc-2.0.git'

  depends_on 'automake'
  depends_on 'pcre'
  depends_on 'gettext'
  depends_on 'libgcrypt'
  depends_on 'libshout'
  depends_on 'libmad'
  depends_on 'libtool'
  depends_on 'flac'
  depends_on 'pkg-config' => :build

  def install
    # Compiler
    cc =   "CC=/Developer/usr/bin/llvm-gcc-4.2"
    cxx =  "CXX=/Developer/usr/bin/llvm-g++-4.2"
    objc = "OBJC=/Developer/usr/bin/llvm-gcc-4.2"

    # gettext is keg-only so make sure vlc finds it
    gettext = Formula.factory("gettext")
    ldf = "LDFLAGS=\"-L#{gettext.lib} -lintl\""
    cfl = "CFLAGS=-I#{gettext.include}"
    print "Adding libintl directly to the environment: #{ENV['LDFLAGS']} and #{ENV['CFLAGS']}"

    # this is needed to find some m4 macros installed by homebrew's pkg-config 
    aclocal = "ACLOCAL_ARGS=\"-I /usr/local/share/aclocal\""

    if MacOS.xcode_version.to_f >= 4.3
      if MacOS.mountain_lion?
        sdk = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk"
      else
        sdk = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.6.sdk"
      end
    else
      sdk = "/Developer/SDKs/MacOSX10.6.sdk"
    end

    exp = ""
    if MacOS.xcode_version.to_f >= 4.3
      exp = "export #{aclocal}; export #{ldf}; export #{cfl}; export SDKROOT=#{sdk}"
    else
      exp = "export #{path}; export #{aclocal}; export #{cc}; export #{cxx}; export #{objc}; export #{ldf}; export #{cfl}"
    end

    darwinVer = "x86_64-apple-darwin10"

    # Additional Libs
    # KLN 20/08/2012 Added 'make .ogg' and 'make .vorbis' in order to get this recipe to work on OSX 10.6
    system "#{exp}; cd contrib; mkdir -p osx; cd osx; ../bootstrap --host=#{darwinVer} --build=#{darwinVer}"
    system "#{exp}; cd contrib/osx; make prebuilt"
    if MacOS.xcode_version.to_f <= 4.2
      system "cd contrib/osx; make .ogg; make .vorbis"
    end

    # HACK: This file is normally created by the build query git log, but homebrew appears
    # to remove the .git folder just create a blank file so that this step passes 
    system "touch src/revision.txt"

    # VLC
    system "#{exp}; ./bootstrap"
    system "#{exp}; mkdir -p build; cd build; ../extras/package/macosx/configure.sh --disable-x264 --disable-ncurses --disable-asa --disable-macosx --disable-macosx-dialog-provider --with-macosx-sdk=#{sdk} --host=#{darwinVer} --build=#{darwinVer} --prefix=#{prefix}"
    system "#{exp}; cd build; make install"
  end
  
  def patches
    DATA
  end
end

__END__
diff --git a/modules/audio_output/auhal.c b/modules/audio_output/auhal.c
index 2a73ebf..07508c0 100644
--- a/modules/audio_output/auhal.c
+++ b/modules/audio_output/auhal.c
@@ -1443,17 +1443,17 @@ static OSStatus HardwareListener( AudioObjectID inObjectID,  UInt32 inNumberAddr
         {
             /* something changed in the list of devices */
             /* We trigger the audio-device's aout_ChannelsRestart callback */
-            msg_Warn( p_aout, "audio device configuration changed, resetting cache" );
+            //msg_Warn( p_aout, "audio device configuration changed, resetting cache" );
             var_TriggerCallback( p_aout, "audio-device" );
             var_Destroy( p_aout, "audio-device" );
         }
         else if( inAddresses[i].mSelector == kAudioDevicePropertyDeviceIsAlive )
         {
-            msg_Warn( p_aout, "audio device died, resetting aout" );
+            //msg_Warn( p_aout, "audio device died, resetting aout" );
             var_TriggerCallback( p_aout, "audio-device" );
             var_Destroy( p_aout, "audio-device" );
         } else if (inAddresses[i].mSelector == kAudioStreamPropertyAvailablePhysicalFormats) {
-            msg_Warn(p_aout, "available physical formats for audio device changed, resetting aout");
+            //msg_Warn(p_aout, "available physical formats for audio device changed, resetting aout");
             var_TriggerCallback(p_aout, "audio-device");
             var_Destroy(p_aout, "audio-device");
         }
diff --git a/src/modules/cache.c b/src/modules/cache.c
index 779656a..a56fb5c 100644
--- a/src/modules/cache.c
+++ b/src/modules/cache.c
@@ -396,6 +396,8 @@ static int CacheSaveBank( FILE *file, const module_cache_t *, size_t );
 void CacheSave (vlc_object_t *p_this, const char *dir,
                module_cache_t *entries, size_t n)
 {
+    return;
+
     char *filename = NULL, *tmpname = NULL;
 
     if (asprintf (&filename, "%s"DIR_SEP CACHE_NAME, dir ) == -1)
@@ -445,6 +447,8 @@ static int CacheSaveSubmodule (FILE *, const module_t *);
 static int CacheSaveBank (FILE *file, const module_cache_t *cache,
                           size_t i_cache)
 {
+    return 0;
+
     uint32_t i_file_size = 0;
 
     /* Contains version number */
@@ -524,6 +528,8 @@ error:
 
 static int CacheSaveSubmodule( FILE *file, const module_t *p_module )
 {
+    return 0;
+
     if( !p_module )
         return 0;
     if( CacheSaveSubmodule( file, p_module->next ) )
@@ -546,6 +552,8 @@ error:
 
 static int CacheSaveConfig (FILE *file, const module_t *p_module)
 {
+    return 0;
+
     uint32_t i_lines = p_module->confsize;
 
     SAVE_IMMEDIATE( p_module->i_config_items );

