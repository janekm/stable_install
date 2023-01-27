from PIL import Image
import os
import re
import piexif
import json
from tqdm import tqdm

re_param_code = r'\s*([\w ]+):\s*("(?:\\|\"|[^\"])+"|[^,]*)(?:,|$)'
re_param = re.compile(re_param_code)
re_params = re.compile(r"^(?:" + re_param_code + "){3,}$")
re_imagesize = re.compile(r"^(\d+)x(\d+)$")

tag_replacements = {
    'wlop': 'painting by wlop',
    'enki': 'painting by enki bilal',
    'kagami': 'painting by kagami',
    'laure': 'painting by laure',
    'laureart': 'painting by laure',
    'guweiz': 'painting by guweiz',
    'sakimichan': 'painting by sakimichan',
    'markprinz': 'photo by markprinz',
    'supergirl': 'supergirl',
    'lalisa manobal': 'photo of lalisa manobal',
    'julia': 'photo of julia',
    'emma': 'photo of emma watson',
    'suzu': 'photo of suzu hirose',
    'zhang jingna': 'fashion photo by zhang jingna',
    'roger davies': 'fashion photo by roger davies',
    'paul bellaart': 'fashion photo by paul bellaart',
    'nayo_photo': 'fashion photo by nayo',
    'michael_photo': 'fashion photo by michael',
    'matteu connie': 'fashion photo by matteu connie',
    'marc collins': 'fashion photo by marc collins',
    'lina tesch': 'fashion photo by lina tesch',
    'editorial': 'editorial',
    'beauty': 'beauty',
    'lara jade': 'fashion photo by lara jade',
    'joey wright': 'fashion photo by joey wright',
    'jay mawson': 'fashion photo by jay mawson',
    'james nader': 'editorial photo by james nader',
    'gary lupton': 'fashion photo by gary lupton',
    'david roemer': 'fashion photo by david roemer',
    'cole sproouse': 'editorial photo by cole sproouse',
    'ben watts': 'fashion photo by ben watts',
    'austin hargrave': 'editorial photo by austin hargrave',
    'anita sadowska': 'fashion photo by anita sadowska',
    'andrew yee': 'fashion photo by andrew yee',
    'alana tyler slutsky': 'fashion photo by alana tyler slutsky',
    'soda_stream': 'painting by soda_stream',
    'no humans': '',
    'young': '',
    'greyscale': 'greyscale, B&W',
    'asian': 'asian',
    'supergirl': 'supergirl',
    'alina': 'alina',
    'blackpink': 'blackpink',
    'blurry': 'shallow depth of field',
    'realistic': 'photo',
    'photorealistic': 'photo',
    'blurry': '',
    '1girl': '1girl, girl, woman',
    'woman': '1girl, girl, woman'
}

def parse_generation_parameters(x: str):
    """parses generation parameters string, the one you see in text field under the picture in UI:
```
girl with an artist's beret, determined, blue eyes, desert scene, computer monitors, heavy makeup, by Alphonse Mucha and Charlie Bowater, ((eyeshadow)), (coquettish), detailed, intricate
Negative prompt: ugly, fat, obese, chubby, (((deformed))), [blurry], bad anatomy, disfigured, poorly drawn face, mutation, mutated, (extra_limb), (ugly), (poorly drawn hands), messy drawing
Steps: 20, Sampler: Euler a, CFG scale: 7, Seed: 965400086, Size: 512x512, Model hash: 45dee52b
```

    returns a dict with field values
    """

    res = {}

    prompt = ""
    negative_prompt = ""

    done_with_prompt = False

    *lines, lastline = x.strip().split("\n")
    if not re_params.match(lastline):
        lines.append(lastline)
        lastline = ''

    for i, line in enumerate(lines):
        line = line.strip()
        if line.startswith("Negative prompt:"):
            done_with_prompt = True
            line = line[16:].strip()

        if done_with_prompt:
            negative_prompt += ("" if negative_prompt == "" else "\n") + line
        else:
            prompt += ("" if prompt == "" else "\n") + line

    res["Prompt"] = prompt
    res["Negative prompt"] = negative_prompt

    return res


def read_info_from_image(image):
    items = image.info or {}

    geninfo = items.pop('parameters', None)

    if "exif" in items:
        exif = piexif.load(items["exif"])
        exif_comment = (exif or {}).get("Exif", {}).get(piexif.ExifIFD.UserComment, b'')
        try:
            exif_comment = piexif.helper.UserComment.load(exif_comment)
        except ValueError:
            exif_comment = exif_comment.decode('utf8', errors="ignore")

        items['exif comment'] = exif_comment
        geninfo = exif_comment

        for field in ['jfif', 'jfif_version', 'jfif_unit', 'jfif_density', 'dpi', 'exif',
                      'loop', 'background', 'timestamp', 'duration']:
            items.pop(field, None)

    return geninfo, items

def read_prompt_from_image(image_filename:str) -> str:
    try:
        image = Image.open(image_filename)
        geninfo, _ = read_info_from_image(image)
        if geninfo:
            return parse_generation_parameters(geninfo)["Prompt"]
    except Exception as e:
        print(e)
    return None


def prompt_from_filename(filename:str) -> str:
    return filename.split('(')[0].strip()

directory = os.getcwd() # Get current directory
filenames = [f for f in os.listdir(directory) if f.endswith('.jpg') or f.endswith('.png')]
for filename in tqdm(filenames, desc="Processing"):
    image_path = os.path.join(directory, filename)
    base_name = os.path.splitext(filename)[0]
    txt_file = base_name + '.txt'
    prompt = prompt_from_filename(base_name)
    if os.path.exists(txt_file):
        with open(txt_file, 'r') as f:
            prompt = prompt + ', ' + f.read()
            f.close()
    try:
        image_prompt = read_prompt_from_image(image_path)
        if image_prompt:
            prompt = image_prompt + ', ' + prompt
    except Exception as e:
        print(f'Error opening image {image_path}: {e}')
    for (k, v) in tag_replacements.items():
        if k in prompt and v not in prompt:
            prompt = prompt.replace(k, v)

    print(f"F: {txt_file} P: {prompt}")
    with open(txt_file, 'w') as f:
        f.write(prompt)
        f.close()
