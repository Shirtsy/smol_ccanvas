# smol_ccanvas
 
A smol Computercraft library for sub-character rendering!

## Constructor

### `SmolCanvas.new(width, height)`
- Creates a new SmolCanvas object
- Parameters:
  - `width`: The width of the canvas in terminal characters
  - `height`: The height of the canvas in terminal characters
- Returns: A new SmolCanvas object

## Color Settings

### `SmolCanvas:set_foreground_color(color)`
- Sets the foreground color for drawing operations
- Parameter: `color` (ComputerCraft color value)

### `SmolCanvas:set_background_color(color)`
- Sets the background color for drawing operations
- Parameter: `color` (ComputerCraft color value)

## Canvas Operations

### `SmolCanvas:fill_canvas()`
- Fills the entire canvas with the foreground color

### `SmolCanvas:erase_canvas()`
- Clears the entire canvas to the background color

## Pixels

### `SmolCanvas:draw_pixel(x, y)`
- Sets a pixel to the foreground color
- Parameters: `x`, `y` (Pixel coordinates)

### `SmolCanvas:erase_pixel(x, y)`
- Sets a pixel to the background color
- Parameters: `x`, `y` (Pixel coordinates)

## Lines

### `SmolCanvas:draw_line(x1, y1, x2, y2)`
- Draws a line in the foreground color
- Parameters: `x1`, `y1`, `x2`, `y2` (Start and end coordinates)

### `SmolCanvas:erase_line(x1, y1, x2, y2)`
- Erases a line to the background color
- Parameters: `x1`, `y1`, `x2`, `y2` (Start and end coordinates)

## Rectangles

### `SmolCanvas:draw_rectangle(x1, y1, x2, y2)`
- Draws a filled rectangle in the foreground color
- Parameters: `x1`, `y1`, `x2`, `y2` (Corner coordinates)

### `SmolCanvas:erase_rectangle(x1, y1, x2, y2)`
- Erases a rectangle area to the background color
- Parameters: `x1`, `y1`, `x2`, `y2` (Corner coordinates)

## Ellipses

### `SmolCanvas:draw_ellipse(x1, y1, x2, y2)`
- Draws a filled ellipse in the foreground color
- Parameters: `x1`, `y1`, `x2`, `y2` (Bounding box coordinates)

### `SmolCanvas:erase_ellipse(x1, y1, x2, y2)`
- Erases an ellipse area to the background color
- Parameters: `x1`, `y1`, `x2`, `y2` (Bounding box coordinates)


## Rendering

### `SmolCanvas:get_canvas_blit()`
- Generates blit strings for rendering
- Returns: Three strings for characters, foreground colors, and background colors

### `SmolCanvas:render_canvas(screen_x, screen_y)`
- Renders the canvas to the screen
- Parameters:
  - `screen_x`, `screen_y`: Screen coordinates for the top-left corner of the canvas
