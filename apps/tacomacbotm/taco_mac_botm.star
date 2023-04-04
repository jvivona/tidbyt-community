"""
Applet: Taco Mac BOTM
Summary: Taco Mac Beer of the Month
Description: Show the current Taco Mac Beers of the Month.
Author: jvivona
"""

VERSION = 23094

load("cache.star", "cache")
load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

DEFAULTS = {
    "series": "car",
    "display": "nri",
    "timezone": "America/New_York",
    "time_24": False,
    "date_us": True,
    "api": "https://tidbyt.apis.ajcomputers.com/indy/api/{}/{}.json",
    "ttl": 1800,
    "positions": 16,
}

DEFAULT_WHO = "world"

def main(config):

    image = get_cachable_data("https://tacomac.com/wp-content/uploads/2023/04/April-GA-Beers1.png")

    return render.Root(
        child = render.Row(expanded = True, children = [
            render.Box(width = 24, height = 26, child = render.Image(src = image, height = 24, width = 24)),
            #fade_child(data["name"], data["track"], "{}\n{}\nTV: {}".format(date_str, time_str, data["tv"].upper()), text_color),
        ])
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "who",
                name = "Who?",
                desc = "Who to say hello to.",
                icon = "user",
            ),
        ],
    )

# ##############################################
#           General Funcitons
# ##############################################
def get_cachable_data(url):
    key = url

    data = cache.get(key)
    if data != None:
        return data

    res = http.get(url = url)
    if res.status_code != 200:
        fail("request to %s failed with status code: %d - %s" % (url, res.status_code, res.body()))

    cache.set(key, res.body(), ttl_seconds = DEFAULTS["ttl"])

    return res.body()

def text_justify_trunc(length, text, direction):
    #  thanks to @inxi and @whyamihere / @rs7q5 for the codepoints() and codepoints_ords() help
    chars = list(text.codepoints())
    textlen = len(chars)

    # if string is shorter than desired - we can just use the count of chars (not bytes) and add on spaces - we're good
    if textlen < length:
        for _ in range(0, length - textlen):
            text = " " + text if direction == "right" else text + " "
    else:
        # text is longer - need to trunc it get the list of characters & trunc at length
        text = ""  # clear out text
        for i in range(0, length):
            text = text + chars[i]

    return text
