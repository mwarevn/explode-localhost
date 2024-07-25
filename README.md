# expose-localhost
Expose your localhost to internet

### Usage
- Run from source
```
python3 main.py
```

- if you using debian you can download and install this package (.deb)
  
  https://github.com/mwarevn/expose-localhost/releases/download/expose-localhost.0.1/expose-localhost.deb

```
sudo apt install ./expose-localhost.deb
```


```
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 

sudo dpkg -i cloudflared.deb && 

sudo cloudflared service install eyJhIjoiYWVkN2JiZDU1YTZhMmEzYzdhNTA2ZjUyNDhmNjRkOWUiLCJ0IjoiYzRkNjczOTctODljNi00MzYxLTkxODAtOTY0NmU4ZGI1ODY3IiwicyI6Ik9XRTVNV0V3TURBdE1UTTROUzAwWVRReUxUZ3dORFV0TXpFek1qVXhZVE0xTkRGbCJ9
```
