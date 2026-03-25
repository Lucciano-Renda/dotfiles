#!/usr/bin/env python
import json
import requests
import sys

CITY = "mdz" # Using full name is usually more reliable

def get_weather():
    try:
        # Added a timeout so the bar doesn't hang
        response = requests.get(f"https://wttr.in/{CITY}?format=j1", timeout=10)
        response.raise_for_status() 
        data = response.json()
        
        curr = data['current_condition'][0]
        temp = curr['temp_C']
        desc = curr['weatherDesc'][0]['value']
        
        tooltip = f"<b>{desc} {temp}°C</b>\n"
        # Only take the next 3 days to keep the tooltip clean
        for day in data['weather'][:3]:
            tooltip += f"\n{day['date']}: <span color='#ffb86c'>{day['maxtempC']}°C</span> / <span color='#8be9fd'>{day['mintempC']}°C</span>"

        out = {
            "text": f"{temp}°C",
            "alt": desc,
            "tooltip": tooltip,
            "class": "weather"
        }
        print(json.dumps(out))
    except Exception as e:
        # Outputting error to stderr helps debugging without breaking Waybar's JSON expectation
        print(json.dumps({"text": "N/A", "tooltip": str(e)}))

if __name__ == "__main__":
    get_weather()
