from flask import Flask, render_template
from prometheus_metrics import setup_metrics
app = Flask(__name__)
setup_metrics(app)

@app.route('/')
def run_flask():
  return render_template('home.html')

#@app.route('/coffee')
#def coffee():
#return render_template('coffee.html')
#pass

if __name__ == '__main__':
  app.run(debug=True, host='0.0.0.0')
