from PIL import Image
import os


def image_to_arm_asm(dir_path, output_file):

    # Convert image to RGB565 format (5 bits Red, 6 bits Green, 5 bits Blue)
    #  or BGR565 format (5 bits Blue, 6 bits Green, 5 bits Red)

    with open(output_file, "w") as f:
        f.write(f"    AREA MYCHARS, DATA, READONLY\n")

        f.write(f"CHARS\n")
        for file_name in os.listdir(dir_path):
            image_path = os.path.join(dir_path, file_name)
            file_name = os.path.basename(image_path)

            img = Image.open(image_path).convert("RGB")
            width, height = img.size

            pixel_data = []

            for y in range(height):
                out = 0
                for x in range(width):
                    r, g, b = img.getpixel((x, y))

                    if r and g and b:
                        out |= (1 << (15 - (x)))
                pixel_data.append(out)
            f.write("    DCW ")

            for i, pixel in enumerate(pixel_data):
                f.write(f"0x{pixel:04X}")

                if i == len(pixel_data) - 1:
                    f.write("\n")
                else:
                    f.write(", ")

        f.write(f"\n    END\n")

    print(f"Assembly file {output_file} generated successfully.")


# Choose BGR or RGB depending on hardware
#  or just try both
image_to_arm_asm("./export",
                 "data.s")
