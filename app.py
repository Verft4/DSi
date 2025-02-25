from flask import Flask, request, jsonify
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)

# Carregar dataset
dataset = pd.read_parquet('games.parquet')

def fill_empty_val(data: pd.DataFrame) -> pd.DataFrame:
    data['Genres'] = data['Genres'].fillna("")
    data['Tags'] = data['Tags'].fillna("")
    data['Categories'] = data['Categories'].fillna("")
    data['Combined_Features'] = data['Genres'] + " " + data['Tags']
    data['Combined_Features'] = data['Combined_Features'].fillna("")
    data['Recommendations'] = data['Recommendations'].fillna(0)
    return data

data = fill_empty_val(dataset)

@app.route('/recomendar', methods=['POST'])
def recomendar():
    req = request.json  # Recebe os dados do Flutter como JSON
    plat_pref = req.get("plataforma", "")
    categ_pref = req.get("categoria", "")
    genre_pref = req.get("genero", "")
    tag_pref = req.get("tag", "")

    # Filtrar jogos com base nas preferências
    filtered_data = data[
        (data[plat_pref] == True) &  
        (data['Categories'].str.contains(categ_pref, case=False)) &
        (data['Genres'].str.contains(genre_pref, case=False) if genre_pref else True) &
        (data['Tags'].str.contains(tag_pref, case=False) if tag_pref else True)
    ]

    if filtered_data.empty:
        return jsonify({"recomendacoes": []})  # Nenhum jogo encontrado

    recommendations = filtered_data.sort_values(by='Recommendations', ascending=False).head(10)
    
    return jsonify({"recomendacoes": recommendations['AppID'].tolist()})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
