# elk
ELK with nginx for basic auth

# Run

```bash
docker run -d -p 80:80 -p 5000:5000 -p 5000:5000/udp -p 9200:9200 -e "KIBANA_AUTH=username:password" seancheung/elk:latest
```