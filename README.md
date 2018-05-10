# Pontepretano.com.br jekyll version concept with worker

## TODO

- [ ] Add results for Copa Sulamericana 2013
- [ ] Add results for Copa do Brasil 2017
- [ ] Add results for Copa Sulamericana 2017
- [ ] Add results for Paulistão 2018
- [ ] Add results for Copa do Brasil 2018
- [ ] Add results for Basileirão 2018
- [ ] Parse Globo Blog and ESPM blog

## Cron setup

### Curren active:

*/30 * * * * /bin/bash -c "source .profile && cd /home/tauil/www/pontepretano-jekyll && bundle exec rake news:update > $HOME/cron_news_update_log && bundle exec jekyll build > $HOME/cron_site_build_log && rsync -r --exclude Rakefile --exclude CNAME --exclude Gemfile.lock --exclude /tmp /home/tauil/www/pontepretano-jekyll/_site/* /home/tauil/www/pontepretano.com.br/ && cd /home/tauil/www/pontepretano.com.br/ && git add . && git commit -a -m 'Adds a new site version' && git push"

### Future plan:

```
PP_JEKYLL_PATH=/home/tauil/www/pontepretano-jekyll
PP_COMBR_PATH=/home/tauil/www/pontepretano.com.br

LOAD_NEWS="bundle exec rake news:update >> $HOME/crontab_news_update"
BUILD_SITE="bundle exec jekyll build >> $HOME/crontab_site_build"
SYNC_FOLDERS="rsync -r --exclude Rakefile --exclude CNAME --exclude Gemfile.lock --exclude /tmp $PP_JEKYLL_PATH/_site/* $PP_COMBR_PATH"
COMMIT_AND_PUSH_UPDATES_ON_PP_COMBR='git add . && git commit -a -m "Adds a new site version" && git push'

UPDATE_PP_SITE_COMMAND="source .profile && cd $PP_JEKYLL_PATH && $LOAD_NEWS"
UPDATE_PP_SITE_COMMAND="source .profile && cd $PP_JEKYLL_PATH && $LOAD_NEWS && $BUILD_SITE && $SYNC_FOLDERS && $COMMIT_AND_PUSH_UPDATES_ON_PP_COMBR"


*/2 * * * * /bin/bash -c "$UPDATE_PP_SITE_COMMAND"
```

### Old:

```
cd /home/tauil/www/pontepretano-jekyll && bundle exec rake news:update > $HOME/cron_news_update_log && bundle exec jekyll build > $HOME/cron_site_build_log && rsync -r --exclude Rakefile --exclude CNAME --exclude Gemfile.lock --exclude /tmp /home/tauil/www/pontepretano-jekyll/_site/* /home/tauil/www/pontepretano.com.br/ && cd /home/tauil/www/pontepretano.com.br/ && git add . && git commit -a -m "Adds a new site version" && git push
```