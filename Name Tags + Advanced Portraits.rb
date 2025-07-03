#───────────────────────────────────────────────────────────────────────────────
# Name Tags & Advanced Portraits v2.0
#───────────────────────────────────────────────────────────────────────────────

# Originally by Gela
# Updated by Swdfm for v1.0
# Updated by Aten2049 for v2.0

# REQUIREMENTS
# - Swdfm's modular messages plugin (Should be linked in the Eevee Expo post.)
# - Ensure that the FaceWindowVX is not used in any other scripts
#   or that it is compatible with this script.

#───────────────────────────────────────────────────────────────────────────────
# COMMANDS
#───────────────────────────────────────────────────────────────────────────────

# BASIC PORTRAITS
# \ml[filename]             -> Left portrait with specified file.
# \ml                       -> Left portrait with previous file.
# \mr[filename]             -> Right portrait with specified file.
# \mr                       -> Right portrait with previous file.

# NAME TAGS
# \xn[name]                 -> Name tag with specified name.
# \xn                       -> Name tag with previous name.
# \dxn[name]                -> Dark name tag with specified name.
# \dxn                      -> Dark name tag with previous name.

# COMBINED NAME TAGS AND PORTRAITS
# \xpl[name,filename]       -> Left portrait with name and specified file.
# \xpl[name]                -> Left portrait shortcut. Name must be the same as the filename.
# \xpl                      -> Left portrait with previous file and name.
# \xpr[name,filename]       -> Right portrait with name and specified file.
# \xpr[name]                -> Right portrait shortcut. Name must be the same as the filename.
# \xpr                      -> Right portrait with previous file and name.

# DUAL PORTRAITS
# \plr[left,right]          -> Dual portraits with specified files.
# \plr                      -> Dual portraits with previous files.

# PORTRAIT RESET
# \xpend                    -> Reset portrait system for fresh conversations.

#───────────────────────────────────────────────────────────────────────────────
# FILE LOCATIONS & FEATURES
#───────────────────────────────────────────────────────────────────────────────

# PORTRAIT PATHS (Searched in this order)
#    • Graphics/Faces/
#    • Graphics/Pictures/  
#    • Graphics/Trainers/

# PORTRAIT FLIPPING
#    • Manual: Append "_f" to the filename (e.g., \ml[portrait_f]).
#    • Automatic: Set Gela_Settings::AUTO_FLIP_SIDE to :left, :right, or :both.

# ANIMATIONS
#    • Smooth sliding animations when portraits change.
#    • Configurable animation duration and distance.
#    • Animation can be disabled by setting Gela_Settings::PORTRAIT_SLIDE_ANIMATION to false.

# SCALING AND POSITIONING
#    • Portrait default size is 192x192 pixels and portraits smaller than this are automatically scaled.
#    • Try to keep your portraits as a multiple of 32 pixels for best results.
#    • Use Gela_Settings::PORTRAIT_SCALE to adjust portrait sizes.
#    • Configurable offsets for left and right portraits.

#───────────────────────────────────────────────────────────────────────────────
# PERFORMANCE NOTES
#───────────────────────────────────────────────────────────────────────────────
#   • Bitmap caching reduces repeated processing
#   • Use Gela_Settings.clear_portrait_cache for memory cleanup
#   • Animations only trigger when portraits actually change
#   • Optimized flipping algorithms for smooth performance

#───────────────────────────────────────────────────────────────────────────────
# SETTINGS
#───────────────────────────────────────────────────────────────────────────────
module Gela_Settings

#----- NAME TAG SETTINGS -------------------------------------------------------

# Name tag window position offset (pixels)
    OFFSET_NAME_X = 0          # Horizontal shift from default position
    OFFSET_NAME_Y = 0           # Vertical shift from default position

# Name tag text alignment
# Options: :left (0), :center/:centre (1), :right (2)
    DEFAULT_ALIGNMENT = :centre

# Name tag windowskin files (Graphics/Windowskins/)
# Set to nil to use default windowskin
    DEFAULT_WINDOWSKIN = nil   # "nmbx"
    DEFAULT_WINDOWSKIN_DARK = nil       # "xndark"

# Minimum width for name tag window (pixels)
    NAME_TAG_MIN_WIDTH = 50

#----- PORTRAIT POSITIONING SETTINGS -------------------------------------------

# Base gap between portraits and screen edges (px)
    PORTRAIT_GAP_EDGE = 16
    
# Additional offset for left portraits (px)
    PORTRAIT_OFFSET_LEFT_X = 0
    PORTRAIT_OFFSET_LEFT_Y = 0
    
# Additional offset for right portraits (px)
    PORTRAIT_OFFSET_RIGHT_X = 0
    PORTRAIT_OFFSET_RIGHT_Y = 0
    
# The gap (px) between the top of the messagebox and
    PORTRAIT_GAP_HEIGHT = 0

#----- PORTRAIT APPEARANCE SETTINGS ---------------------------------------------
    
# Portrait window and picture dimensions
# [window_width, window_height, picture_width, picture_height]
    PORTRAIT_SIZES = [224, 224, 192, 192]

# Global scale for all portrait dimensions.
# Set to 1 for default size, 2 for double size, etc.
    PORTRAIT_SCALE = 1

# Whether to show windowskin border for portraits
    SHOW_PORTRAIT_WINDOWSKIN = false

# Automatic portrait flipping based on side.
# Options: :left (always flip left portraits), :right (always flip right portraits),
#          :both (flip both sides), or nil (no auto-flip)
    AUTO_FLIP_SIDE = nil

#----- PORTRAIT ANIMATION SETTINGS ---------------------------------------------

# Enable/disable sliding animation for portrait changes
    PORTRAIT_SLIDE_ANIMATION = true

# Animation timing (in frames, 60 FPS = 1 second)
    PORTRAIT_SLIDE_DURATION = 60

# Slide distance for portrait animations (in pixels)
# This is the distance the portrait will slide in or out during the animation.
    PORTRAIT_SLIDE_DISTANCE = 100

#───────────────────────────────────────────────────────────────────────────────
# UTILITY METHODS
#───────────────────────────────────────────────────────────────────────────────
    
# Clear portrait cache (useful for memory management or when images change)
    def self.clear_portrait_cache
        PortraitCache.clear_cache
    end
    
    module_function
    
#-------------------------------
# Allows multiple options to be entered for DEFAULT_ALIGNMENT
    def default_align
        ret = DEFAULT_ALIGNMENT
        
        return ret if ret.is_a?(Integer)
        
        case ret.to_s.downcase
        when "left" then return 0
        when "right" then return 2
        end
        
        1 # Default to center alignment
    end
end

#-------------------------------
# "New" Method to display name tag window
def pbDisplayNameWindow(msgwindow, dark, param)
    a_str = ["al>", "ac>", "ar>"][Gela_Settings.default_align]
    
    name_window = Window_AdvancedTextPokemon.new("<" + a_str + param.to_s + "</" + a_str)
    
    windowskin_str = dark ? Gela_Settings::DEFAULT_WINDOWSKIN_DARK : Gela_Settings::DEFAULT_WINDOWSKIN
    
    if windowskin_str
        name_window.setSkin("Graphics/Windowskins/" + windowskin_str)
    end
    
    name_window.resizeToFit(name_window.text, Graphics.width)
    
    min_width = Gela_Settings::NAME_TAG_MIN_WIDTH
    
    name_window.width = [min_width, name_window.width].max
    
    name_window.y = msgwindow.y - name_window.height
    
    if name_window.y + name_window.height > msgwindow.y + msgwindow.height
        # msgwindow at top. puts name tag underneath
        name_window.y = msgwindow.y + msgwindow.height
    end
    
    name_window.x += Gela_Settings::OFFSET_NAME_X
    name_window.y += Gela_Settings::OFFSET_NAME_Y
    
    name_window.viewport = msgwindow.viewport
    
    name_window.z = msgwindow.z + 20
    
    name_window
end

#-------------------------------
# FaceWindowVX Class Override
class FaceWindowVX < SpriteWindow_Base
    def initialize(face, sizes = nil, side = nil)
        @sizes = sizes || [128, 128, 96, 96]
        @side = side  # :left, :right, or nil
        
        super(0, 0, @sizes[0], @sizes[1])
        self.windowskin = nil unless Gela_Settings::SHOW_PORTRAIT_WINDOWSKIN
        
        faceinfo = face.split(",")
        
        # Check if filename ends with _f for horizontal flip
        filename = faceinfo[0]
        @flip_horizontal = filename && filename.end_with?("_f")
        if @flip_horizontal
            filename = filename[0...-2]  # Remove the _f suffix
        end
        
        # Apply auto-flip based on side setting
        auto_flip_setting = Gela_Settings::AUTO_FLIP_SIDE
        if auto_flip_setting && @side
            case auto_flip_setting
            when :left
                @flip_horizontal = true if @side == :left
            when :right  
                @flip_horizontal = true if @side == :right
            when :both
                @flip_horizontal = true
            end
        end
        
        # Handle nil or empty filename
        if filename.nil? || filename.empty?
            # Create a blank bitmap and return early
            self.contents = Bitmap.new(@sizes[2], @sizes[3])
            return
        end
        
        facefile = pbResolveBitmap("Graphics/Faces/" + filename)
        facefile ||= pbResolveBitmap("Graphics/Pictures/" + filename)
        facefile ||= pbResolveBitmap("Graphics/Trainers/" + filename)
        
        # Handle case where bitmap file is not found
        if facefile.nil?
            # Create a blank bitmap and return early
            self.contents = Bitmap.new(@sizes[2], @sizes[3])
            return
        end
        
        self.contents&.dispose
        
        @faceIndex = faceinfo[1].to_i
        @facebitmaptmp = AnimatedBitmap.new(facefile)
        
        # Create cache key for this specific portrait configuration
        cache_key = "#{filename}_#{@faceIndex}_#{@sizes.join('_')}_#{@flip_horizontal}"
        
        # Use cached bitmap if available, otherwise create and cache it
        @facebitmap = PortraitCache.get_cached_bitmap(cache_key, @sizes) do
            process_portrait_bitmap
        end
        
        self.contents = @facebitmap
    end
    
    private
    
    def process_portrait_bitmap
        result_bitmap = Bitmap.new(@sizes[2], @sizes[3])
        
        # Get source dimensions (original size or face grid size)
        if @facebitmaptmp.bitmap.width > @sizes[2] && @facebitmaptmp.bitmap.height > @sizes[3]
            # This is likely a face grid, use standard face size
            src_width = @facebitmaptmp.bitmap.width / 4
            src_height = @facebitmaptmp.bitmap.height / 4
            src_x = (@faceIndex % 4) * src_width
            src_y = (@faceIndex / 4) * src_height
        else
            # This is a single image, use full size
            src_width = @facebitmaptmp.bitmap.width
            src_height = @facebitmaptmp.bitmap.height
            src_x = 0
            src_y = 0
        end
        
        # Scale and optionally flip the image
        if @flip_horizontal
            # Use optimized horizontal flip with stretch_blt
            temp_bitmap = Bitmap.new(@sizes[2], @sizes[3])
            temp_bitmap.stretch_blt(
                Rect.new(0, 0, @sizes[2], @sizes[3]),
                @facebitmaptmp.bitmap,
                Rect.new(src_x, src_y, src_width, src_height)
            )
            
            # Efficient horizontal flip using blt in reverse
            (0...@sizes[2]).each do |x|
                result_bitmap.blt(@sizes[2] - 1 - x, 0, temp_bitmap, Rect.new(x, 0, 1, @sizes[3]))
            end
            
            temp_bitmap.dispose
        else
            result_bitmap.stretch_blt(
                Rect.new(0, 0, @sizes[2], @sizes[3]),
                @facebitmaptmp.bitmap,
                Rect.new(src_x, src_y, src_width, src_height)
            )
        end
        
        result_bitmap
    end
    
    def update
        super
        
        # Only update for animated bitmaps, and avoid reprocessing static images
        if @facebitmaptmp.totalFrames > 1
            @facebitmaptmp.update
            
            # Only rebuild the bitmap if the frame actually changed
            if @facebitmaptmp.currentFrame != @last_frame
                @last_frame = @facebitmaptmp.currentFrame
                
                # Get source dimensions (original size or face grid size)
                if @facebitmaptmp.bitmap.width > @sizes[2] && @facebitmaptmp.bitmap.height > @sizes[3]
                    # This is likely a face grid, use standard face size
                    src_width = @facebitmaptmp.bitmap.width / 4
                    src_height = @facebitmaptmp.bitmap.height / 4
                    src_x = (@faceIndex % 4) * src_width
                    src_y = (@faceIndex / 4) * src_height
                else
                    # This is a single image, use full size
                    src_width = @facebitmaptmp.bitmap.width
                    src_height = @facebitmaptmp.bitmap.height
                    src_x = 0
                    src_y = 0
                end
                
                # Scale and optionally flip the image (optimized version)
                if @flip_horizontal
                    # Use optimized horizontal flip
                    temp_bitmap = Bitmap.new(@sizes[2], @sizes[3])
                    temp_bitmap.stretch_blt(
                        Rect.new(0, 0, @sizes[2], @sizes[3]),
                        @facebitmaptmp.bitmap,
                        Rect.new(src_x, src_y, src_width, src_height)
                    )
                    
                    # Clear the existing bitmap
                    @facebitmap.clear
                    
                    # Efficient horizontal flip using blt
                    (0...@sizes[2]).each do |x|
                        @facebitmap.blt(@sizes[2] - 1 - x, 0, temp_bitmap, Rect.new(x, 0, 1, @sizes[3]))
                    end
                    
                    temp_bitmap.dispose
                else
                    @facebitmap.stretch_blt(
                        Rect.new(0, 0, @sizes[2], @sizes[3]),
                        @facebitmaptmp.bitmap,
                        Rect.new(src_x, src_y, src_width, src_height)
                    )
                end
            end
        end
    end
    
    def dispose
        @facebitmap&.dispose
        @facebitmaptmp&.dispose
        super
    end
end

#-------------------------------
# New FaceWindowVX Class for Advanced Portraits
class FaceWindowVXNew < FaceWindowVX
    attr_accessor :target_x, :animation_frame, :animation_duration, :slide_direction
    
    def initialize(face, slide_direction = :left)
        # Apply scale to portrait sizes
        scale = Gela_Settings::PORTRAIT_SCALE
        scaled_sizes = [
            (Gela_Settings::PORTRAIT_SIZES[0] * scale).to_i,  # window width
            (Gela_Settings::PORTRAIT_SIZES[1] * scale).to_i,  # window height
            (Gela_Settings::PORTRAIT_SIZES[2] * scale).to_i,  # picture width
            (Gela_Settings::PORTRAIT_SIZES[3] * scale).to_i   # picture height
        ]
        
        super(face, scaled_sizes, slide_direction)  # Pass slide_direction as side parameter
        
        # Initialize animation variables
        @slide_direction = slide_direction
        @animation_frame = 0
        @animation_duration = Gela_Settings::PORTRAIT_SLIDE_DURATION
        @target_x = 0
        @start_x = 0
        @animating = false
        @animation_start_time = nil
    end
    
    def start_slide_animation(target_x, animate = true)
        @target_x = target_x
        
        if !animate || !Gela_Settings::PORTRAIT_SLIDE_ANIMATION
            # No animation, just set position directly
            self.x = target_x
            @animating = false
            return
        end
        
        @animating = true
        
        # Calculate starting position based on slide direction
        slide_distance = Gela_Settings::PORTRAIT_SLIDE_DISTANCE
        if @slide_direction == :left
            @start_x = target_x - slide_distance
        else # :right
            @start_x = target_x + slide_distance
        end
        
        # Initialize animation state
        @animation_frame = 0
        @animation_duration = Gela_Settings::PORTRAIT_SLIDE_DURATION
        
        # Set initial position
        self.x = @start_x
    end
    
    def update_animation
        return unless @animating
        
        @animation_frame += 1
        progress = @animation_frame.to_f / @animation_duration
        
        if progress >= 1.0
            # Animation complete
            self.x = @target_x
            @animating = false
        else
            # Continue animation
            eased_progress = 1 - (1 - progress) ** 3  # Ease-out cubic
            current_x = @start_x + ((@target_x - @start_x) * eased_progress)
            self.x = current_x.to_i
        end
    end
    
    def update
        super
        update_animation
    end
    
    def animating?
        @animating
    end
    
    def dispose
        super
    end
end

#-------------------------------
# GameTemp
# Stores name within name tag
#    in case of next time
class Game_Temp
    attr_accessor :name_tag, :port_path_left, :port_path_right, :current_portrait_left, :current_portrait_right, :last_portrait_side, :portraits_cleared_by_side_switch
end

#-------------------------------
# Gets last stored name tag
#    or stores name tag name
def pbAdjustNameTag(param)
    if param == ""
        return $game_temp.name_tag || param
    end
    
    $game_temp.name_tag = param
    
    param
end

#-------------------------------
# Gets last stored portrait path
#    or stores portrait path name
def pbAdjustPortrait(param, is_right = false)
    if param == ""
        if is_right
            result = $game_temp.port_path_right || param
            return result
        else
            result = $game_temp.port_path_left || param
            return result
        end
    end
    
    if is_right
        $game_temp.port_path_right = param
    else
        $game_temp.port_path_left = param
    end
    
    param
end

#-------------------------------
# Reset portrait tracking for fresh conversations
def pbResetPortraitTracking
    $game_temp.current_portrait_left = nil
    $game_temp.current_portrait_right = nil
    $game_temp.last_portrait_side = nil
    $game_temp.portraits_cleared_by_side_switch = {}
    $game_temp.name_tag = nil
    $game_temp.port_path_left = nil
    $game_temp.port_path_right = nil
end

#-------------------------------
# Helper methods for reducing code duplication
module PortraitHelpers
    # Create a name tag window
    def self.create_name_tag(hash, param, dark = false)
        param = pbAdjustNameTag(param)
        
        hash["windows_name"]&.dispose
        hash["windows_name"] = pbDisplayNameWindow(hash["msg_window"], dark, param)
        hash["windows_name"].viewport = hash["msg_window"].viewport
        hash["windows_name"].z = hash["msg_window"].z + 20
    end
    
    # Create a portrait window with positioning and animation
    def self.create_portrait(hash, param, direction, animate = true, is_dual_command = false)
        direction_str = direction.to_s
        is_right = direction == :right
        
        param = pbAdjustPortrait(param, is_right)
        
        # Skip if parameter is empty or nil
        if param.nil? || param.empty?
            return
        end
        
        window_key = "windows_face_#{direction_str}"
        
        # Check if this portrait is already displayed on this side
        current_portrait = is_right ? $game_temp.current_portrait_right : $game_temp.current_portrait_left
        portrait_changed = current_portrait != param
        
        # Initialize the cleared tracking if it doesn't exist
        $game_temp.portraits_cleared_by_side_switch ||= {}
        
        # Check if this side was cleared by a previous side switch
        side_key = is_right ? :right : :left
        if $game_temp.portraits_cleared_by_side_switch[side_key]
            portrait_changed = true
            $game_temp.portraits_cleared_by_side_switch[side_key] = false
        end
        
        # Check if we're switching sides (for single portrait commands only)
        side_switched = false
        if !is_dual_command && $game_temp.last_portrait_side
            # We're switching sides if:
            # 1. Last side was different from current side
            # 2. And the opposite side had a portrait
            opposite_side = is_right ? :left : :right
            opposite_portrait = is_right ? $game_temp.current_portrait_left : $game_temp.current_portrait_right
            
            if $game_temp.last_portrait_side != direction && opposite_portrait
                side_switched = true
                
                # Mark that the opposite side was cleared by side switch
                $game_temp.portraits_cleared_by_side_switch[opposite_side] = true
                
                # Clear the opposite side tracking since we're switching away from it
                if is_right
                    $game_temp.current_portrait_left = nil
                else
                    $game_temp.current_portrait_right = nil
                end
                
                # Force animation if same portrait but switching sides
                if current_portrait == param
                    portrait_changed = true
                end
            end
        end
        
        # Always dispose existing window to avoid conflicts
        hash[window_key]&.dispose
        
        # Always create the portrait window
        hash[window_key] = FaceWindowVXNew.new(param, direction)
        
        # Update the current portrait tracker
        if is_right
            $game_temp.current_portrait_right = param
        else
            $game_temp.current_portrait_left = param
        end
        
        # Update the last portrait side (only for single-side commands)
        if !is_dual_command
            $game_temp.last_portrait_side = direction
        end
        
        # Calculate position
        gap = Gela_Settings::PORTRAIT_GAP_EDGE
        target_x = is_right ? Graphics.width - hash[window_key].width - gap : gap
        
        hash[window_key].y = hash["msg_window"].y - hash[window_key].height - Gela_Settings::PORTRAIT_GAP_HEIGHT
        
        # Apply side-specific offsets
        if is_right
            target_x += Gela_Settings::PORTRAIT_OFFSET_RIGHT_X
            hash[window_key].y += Gela_Settings::PORTRAIT_OFFSET_RIGHT_Y
        else
            target_x += Gela_Settings::PORTRAIT_OFFSET_LEFT_X
            hash[window_key].y += Gela_Settings::PORTRAIT_OFFSET_LEFT_Y
        end
        
        hash[window_key].viewport = hash["msg_window"].viewport
        hash[window_key].z = hash["msg_window"].z - 10
        
        # Only animate if the portrait has actually changed
        hash[window_key].start_slide_animation(target_x, animate && portrait_changed)
        
        # If animating, run the animation loop
        if animate && portrait_changed
            duration = Gela_Settings::PORTRAIT_SLIDE_DURATION
            (0..duration).each do |frame|
                hash[window_key].update_animation
                Graphics.update if frame < duration
            end
        end
    end
    
    # Create dual portraits with independent animation checks
    def self.create_dual_portraits(hash, left_portrait, right_portrait, animate = true)
        # Save the current cleared state before any dual processing
        $game_temp.portraits_cleared_by_side_switch ||= {}
        left_was_cleared = $game_temp.portraits_cleared_by_side_switch[:left]
        right_was_cleared = $game_temp.portraits_cleared_by_side_switch[:right]
        
        # Process the portrait parameters through pbAdjustPortrait to ensure storage
        left_portrait = pbAdjustPortrait(left_portrait, false)
        right_portrait = pbAdjustPortrait(right_portrait, true)
        
        # Check current portrait state to determine if animation is needed
        left_current = $game_temp.current_portrait_left
        right_current = $game_temp.current_portrait_right
        
        # For dual portraits, if we had a recent side switch, both sides should animate
        # This handles the case where: single left -> single right -> dual (both should animate)
        recent_side_switch = left_was_cleared || right_was_cleared
        
        left_changed = (left_current != left_portrait) || left_was_cleared
        right_changed = (right_current != right_portrait) || right_was_cleared
        
        # Handle left portrait with preserved animation decision
        hash["windows_face_left"]&.dispose
        if left_portrait && !left_portrait.empty?
            hash["windows_face_left"] = FaceWindowVXNew.new(left_portrait, :left)
            $game_temp.current_portrait_left = left_portrait
            
            # Calculate left position
            gap = Gela_Settings::PORTRAIT_GAP_EDGE
            left_target_x = gap + Gela_Settings::PORTRAIT_OFFSET_LEFT_X
            hash["windows_face_left"].y = hash["msg_window"].y - hash["windows_face_left"].height - Gela_Settings::PORTRAIT_GAP_HEIGHT + Gela_Settings::PORTRAIT_OFFSET_LEFT_Y
            hash["windows_face_left"].viewport = hash["msg_window"].viewport
            hash["windows_face_left"].z = hash["msg_window"].z - 10
            hash["windows_face_left"].start_slide_animation(left_target_x, animate && left_changed)
        else
            hash["windows_face_left"] = nil
            $game_temp.current_portrait_left = nil
        end
        
        # Handle right portrait with preserved animation decision  
        hash["windows_face_right"]&.dispose
        if right_portrait && !right_portrait.empty?
            hash["windows_face_right"] = FaceWindowVXNew.new(right_portrait, :right)
            $game_temp.current_portrait_right = right_portrait
            
            # Calculate right position
            gap = Gela_Settings::PORTRAIT_GAP_EDGE
            right_target_x = Graphics.width - hash["windows_face_right"].width - gap + Gela_Settings::PORTRAIT_OFFSET_RIGHT_X
            hash["windows_face_right"].y = hash["msg_window"].y - hash["windows_face_right"].height - Gela_Settings::PORTRAIT_GAP_HEIGHT + Gela_Settings::PORTRAIT_OFFSET_RIGHT_Y
            hash["windows_face_right"].viewport = hash["msg_window"].viewport
            hash["windows_face_right"].z = hash["msg_window"].z - 10
            hash["windows_face_right"].start_slide_animation(right_target_x, animate && right_changed)
        else
            hash["windows_face_right"] = nil
            $game_temp.current_portrait_right = nil
        end
        
        # If either side is animating, run a collective animation loop
        if (animate && left_changed) || (animate && right_changed)
            duration = Gela_Settings::PORTRAIT_SLIDE_DURATION
            (0..duration).each do |frame|
                hash["windows_face_left"].update_animation if hash["windows_face_left"]
                hash["windows_face_right"].update_animation if hash["windows_face_right"]
                Graphics.update if frame < duration
            end
        end
        
        # Clear the cleared flags since we've processed them
        $game_temp.portraits_cleared_by_side_switch[:left] = false
        $game_temp.portraits_cleared_by_side_switch[:right] = false
    end
    
    # Parse combined parameters (name, filename)
    def self.parse_combined_params(param)
        return ["", ""] if param.nil? || param.empty?
        
        parts = param.split(",")
        if parts.length >= 2
            name = parts[0].strip
            filename = parts[1].strip
        else
            name = param.strip
            filename = param.strip
            # Remove _f from name for display purposes
            name = name[0...-2] if name && name.end_with?("_f")
        end
        [name, filename]
    end
    
    # Parse dual portrait parameters
    def self.parse_dual_params(param)
        return ["", ""] if param.nil? || param.empty?
        
        parts = param.split(",")
        if parts.length >= 2
            [parts[0].strip, parts[1].strip]
        else
            [param.strip, param.strip]
        end
    end
    
    # Create a control handler with both before_appears and during_loop
    def self.create_control_handler(before_proc, during_proc)
        {
            "both" => true,
            "before_appears" => before_proc,
            "during_loop" => during_proc
        }
    end
    
    # Clear portrait tracking when disposing portraits
    def self.clear_portrait_tracking(hash, direction = nil)
        if direction.nil?
            # Clear both sides
            $game_temp.current_portrait_left = nil
            $game_temp.current_portrait_right = nil
            hash["windows_face_left"]&.dispose
            hash["windows_face_right"]&.dispose
            hash["windows_face_left"] = nil
            hash["windows_face_right"] = nil
        else
            # Clear specific side
            direction_str = direction.to_s
            window_key = "windows_face_#{direction_str}"
            
            if direction == :right
                $game_temp.current_portrait_right = nil
            else
                $game_temp.current_portrait_left = nil
            end
            
            hash[window_key]&.dispose
            hash[window_key] = nil
        end
    end
end

#=============================================================================
# For Modular Messages
#-------------------------------
# Control Handlers: Name Tags
Modular_Messages::Controls.add("xn", PortraitHelpers.create_control_handler(
    proc { |hash, param| PortraitHelpers.create_name_tag(hash, param, hash["current_control"] == "dxn") },
    proc { |hash, param| PortraitHelpers.create_name_tag(hash, param, hash["current_control"] == "dxn") }
))

Modular_Messages::Controls.copy("xn", "dxn")

#-------------------------------
# Control Handlers: Advanced Portraits
Modular_Messages::Controls.add("ml", PortraitHelpers.create_control_handler(
    proc { |hash, param|
        direction = hash["current_control"] == "ml" ? :left : :right
        PortraitHelpers.create_portrait(hash, param, direction, true)
    },
    proc { |hash, param|
        direction = hash["current_control"] == "ml" ? :left : :right
        PortraitHelpers.create_portrait(hash, param, direction, false)
    }
))

Modular_Messages::Controls.copy("ml", "mr")

#-------------------------------
# Control Handlers: Combined Name Tags and Portraits
Modular_Messages::Controls.add("xpl", PortraitHelpers.create_control_handler(
    proc { |hash, param|
        direction = hash["current_control"] == "xpl" ? :left : :right
        name, filename = PortraitHelpers.parse_combined_params(param)
        
        # Create nameplate first so it appears immediately
        PortraitHelpers.create_name_tag(hash, name, false)
        PortraitHelpers.create_portrait(hash, filename, direction, true)
    },
    proc { |hash, param|
        direction = hash["current_control"] == "xpl" ? :left : :right
        name, filename = PortraitHelpers.parse_combined_params(param)
        
        # Create nameplate first so it appears immediately
        PortraitHelpers.create_name_tag(hash, name, false)
        PortraitHelpers.create_portrait(hash, filename, direction, false)
    }
))

Modular_Messages::Controls.copy("xpl", "xpr")

#-------------------------------
# Control Handlers: Dual Portraits (Left and Right)
Modular_Messages::Controls.add("plr", PortraitHelpers.create_control_handler(
    proc { |hash, param|
        left_portrait, right_portrait = PortraitHelpers.parse_dual_params(param)
        
        PortraitHelpers.create_dual_portraits(hash, left_portrait, right_portrait, true)
    },
    proc { |hash, param|
        left_portrait, right_portrait = PortraitHelpers.parse_dual_params(param)
        
        PortraitHelpers.create_dual_portraits(hash, left_portrait, right_portrait, false)
    }
))

#-------------------------------
# Control Handler: Reset Portrait System
Modular_Messages::Controls.add("xpend", PortraitHelpers.create_control_handler(
    proc { |hash, param| pbResetPortraitTracking },
    proc { |hash, param| pbResetPortraitTracking }
))

#-------------------------------
# Bitmap Cache for Performance Optimization
module PortraitCache
    @@cache = {}
    
    def self.get_cached_bitmap(cache_key, sizes, &block)
        unless @@cache[cache_key]
            @@cache[cache_key] = block.call
        end
        
        # Return a copy to avoid modifying the cached version
        cached = @@cache[cache_key]
        copy = Bitmap.new(cached.width, cached.height)
        copy.blt(0, 0, cached, Rect.new(0, 0, cached.width, cached.height))
        copy
    end
    
    def self.clear_cache
        @@cache.each_value(&:dispose)
        @@cache.clear
    end
end
