'use strict';

const exec = require('child_process').exec;

exec('/var/www/vendor/drush/drush/drush pm:security -n', {
  cwd: '/var/www'
}, (err, result) => {
  if (!err) {
    console.error('No security updates found');
    process.exit(0);
  }

  const match = err.message.match(/Try running: (composer require .+ --update-with-dependencies)/);
  if (!match) {
    console.error('No security updates found');
    process.exit(0);
  }

  const updateCommand = match[1];

  exec(updateCommand, {
    cwd: '/var/www'
  }, (err, result) => {
    if (err) {
      console.error('Error installing updates:', err);
      process.exit(1);
    }
    console.error('Updates succesfully installed');
    console.log('Changed: /var/www/composer.json => /composer.json');
    console.log('Changed: /var/www/composer.lock => /composer.lock');
  });
});
